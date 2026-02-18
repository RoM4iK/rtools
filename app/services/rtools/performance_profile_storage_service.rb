# frozen_string_literal: true

# Service for storing performance profiles to the filesystem (development only)
class Dev::PerformanceProfileStorageService < BaseService
  option :profile_data

  def call
    return Failure("Performance profiler is only available in development") unless Rails.env.development?

    storage_dir = Rails.root.join("tmp", "performance_profiles")
    FileUtils.mkdir_p(storage_dir)

    # Generate URL-safe slug from the request path
    slug = generate_slug(profile_data[:url])
    file_path = storage_dir.join("#{slug}.json")

    # Read existing profiles
    profiles = load_existing_profiles(file_path)

    # Add new profile
    profiles << profile_data

    # Keep only the most recent 20, sorted by timestamp descending
    profiles = profiles.sort_by { |p| p[:timestamp] }.reverse.take(20)

    # Write back to disk
    File.write(file_path, JSON.pretty_generate(profiles))

    Success(file_path: file_path, profile_count: profiles.count)
  rescue => e # awareness rescue: convert unexpected errors to service failure result
    Failure("Failed to store performance profile: #{e.message}")
  end

  private

  def generate_slug(url)
    # Convert URL to a safe filename
    # /contacts -> contacts
    # /contacts/123 -> contacts_123
    # / -> root
    slug = url.gsub("/", "_").gsub(/^_/, "").presence || "root"
    slug = "root" if slug.blank?

    # Remove any non-alphanumeric characters except underscores
    slug.gsub(/[^a-zA-Z0-9_]/, "_").gsub(/_+/, "_").downcase
  end

  def load_existing_profiles(file_path)
    return [] unless File.exist?(file_path)

    JSON.parse(File.read(file_path), symbolize_names: true)
  rescue JSON::ParserError => e # awareness rescue: handle expected error with proper response
    Rails.logger.error "Failed to parse existing profiles: #{e.message}"
    []
  end
end
