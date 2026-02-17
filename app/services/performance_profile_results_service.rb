# frozen_string_literal: true

module Rtools
  # Service for reading and aggregating performance profile results (development only)
  class PerformanceProfileResultsService
    attr_reader :page_slug

    def initialize(page_slug: nil)
      @page_slug = page_slug
    end

    def self.call(**kwargs)
      new(**kwargs).call
    end

    def call
      return failure("Performance profiles are only available in development") unless Rails.env.development?

      dir_path = Rails.root.join("tmp", "performance_profiles")

      return success(pages: [], message: "No performance profiles found. Visit some pages to generate profiles.") unless Dir.exist?(dir_path)

      if page_slug
        # Load specific page
        load_page_profiles(dir_path, page_slug)
      else
        # Load all pages with aggregate statistics
        load_all_pages(dir_path)
      end
    rescue => e # awareness rescue: convert unexpected errors to service failure result
      failure("Failed to load performance profiles: #{e.message}")
    end

    private

    def load_page_profiles(dir_path, slug)
      # Try multiple filename patterns to handle double .json extensions
      possible_filenames = [
        "#{slug}.json.json", # For slugs like "transfers_incoming" with file "transfers_incoming.json.json"
        slug.end_with?(".json") ? slug : "#{slug}.json", # Standard pattern
        slug # Exact match
      ]

      file_path = possible_filenames.map { |fn| dir_path.join(fn) }.find { |path| File.exist?(path) }

      return success(page_slug: slug, profiles: [], message: "No profiles found for this page") unless file_path

      profiles = parse_json_with_auto_fix(file_path)

      success(page_slug: slug, url: profiles.first[:url], profiles: profiles, profile_count: profiles.count)
    end

    def load_all_pages(dir_path)
      pages = []

      Dir
        .glob(dir_path.join("*.json"))
        .each do |file_path|
          profiles = parse_json_with_auto_fix(file_path)
          next if profiles.empty?

          # Calculate statistics
          load_times = profiles.map { |p| p[:total_time] }.compact
          sql_times = profiles.map { |p| p[:sql_time] }.compact
          sql_query_counts = profiles.map { |p| p[:sql_queries]&.count || 0 }

          pages << {
            page_slug: File.basename(file_path, ".json"),
            url: profiles.first[:url],
            profile_count: profiles.count,
            mean_load_time: calculate_mean(load_times),
            median_load_time: calculate_median(load_times),
            p95_load_time: calculate_percentile(load_times, 95),
            mean_sql_time: calculate_mean(sql_times),
            mean_sql_queries: calculate_mean(sql_query_counts),
            latest_timestamp: profiles.first[:timestamp]
          }
        end

      # Sort by latest timestamp descending
      pages = pages.sort_by { |p| p[:latest_timestamp] }.reverse

      success(pages: pages)
    end

    def parse_json_with_auto_fix(file_path)
      content = File.read(file_path)
      JSON.parse(content, symbolize_names: true)
    rescue JSON::ParserError => e # awareness rescue: attempt to auto-fix malformed JSON from profiling tool output
      # Attempt to auto-fix common JSON issues
      Rails.logger.warn("JSON parse error in #{file_path}: #{e.message}. Attempting auto-fix...")

      fixed_content = auto_fix_json(content, e.message)

      if fixed_content != content
        # Save the fixed version
        File.write(file_path, fixed_content)
        Rails.logger.info("Auto-fixed JSON file: #{file_path}")

        # Try parsing again
        JSON.parse(fixed_content, symbolize_names: true)
      else
        # If we couldn't fix it, re-raise the original error
        raise
      end
    end

    def auto_fix_json(content, error_message)
      fixed = content.dup

      # Fix: Extra closing bracket at the end (e.g., "]]" should be "]")
      if error_message.include?("unexpected token") && error_message.include?("']'")
        # Remove duplicate closing brackets at the end
        fixed = fixed.sub(/\]\s*\]\s*\z/, "]\n")
      end

      # Fix: Missing closing bracket
      if error_message.include?("unexpected end of file")
        # Check if we're missing a closing bracket for an array
        open_brackets = content.scan(/\[/).count
        close_brackets = content.scan(/\]/).count

        fixed += "\n]" * (open_brackets - close_brackets) if open_brackets > close_brackets
      end

      # Fix: Trailing comma before closing bracket
      fixed = fixed.gsub(/,(\s*[\]\}])/, '\1')

      fixed
    end

    def calculate_mean(values)
      return 0.0 if values.empty?
      (values.sum / values.count.to_f).round(2)
    end

    def calculate_median(values)
      return 0.0 if values.empty?
      sorted = values.sort
      mid = sorted.count / 2

      sorted.count.odd? ? sorted[mid].round(2) : ((sorted[mid - 1] + sorted[mid]) / 2.0).round(2)
    end

    def calculate_percentile(values, percentile)
      return 0.0 if values.empty?
      sorted = values.sort
      index = ((percentile / 100.0) * sorted.count).ceil - 1
      sorted[[index, 0].max].round(2)
    end

    def success(data)
      Result.new(true, data)
    end

    def failure(message)
      Result.new(false, nil, message)
    end

    # Simple result object
    class Result
      attr_reader :data, :error

      def initialize(success, data = nil, error = nil)
        @success = success
        @data = data
        @error = error
      end

      def success?
        @success
      end

      def failure
        @error
      end

      def value!
        @data
      end
    end
  end
end
