# frozen_string_literal: true

module Rtools
  # This module ensures that rescue blocks in the codebase have awareness comments
  # It fails checks if non-aware rescue blocks are found
  module RescueAwarenessChecker
    class << self
      def check_all_files!(directories = ["app"])
        violations = find_violations(directories)

        if violations.any?
          message = build_error_message(violations)
          raise message
        end
      end

      private

      def find_violations(directories)
        violations = []

        directories.each do |dir|
          next unless Dir.exist?(dir)

          Dir.glob(File.join(dir, "**", "*.rb")).each do |file|
            file_violations = check_file(file)
            violations.concat(file_violations) if file_violations.any?
          end
        end

        violations
      end

      def check_file(file_path)
        violations = []
        content = File.read(file_path)
        lines = content.split("\n")

        lines.each_with_index do |line, idx|
          # Check for explicit rescue blocks
          if line.match?(/^\s*rescue/)
            has_awareness = line.include?("# awareness rescue")

            # Check the line before
            if !has_awareness && idx > 0
              previous_line = lines[idx - 1]
              has_awareness = previous_line&.include?("# awareness rescue")
            end

            violations << { file: file_path, line: idx + 1, content: line.strip } unless has_awareness
          end

          # Check for inline rescue statements (e.g., "value = parse_date(str) rescue nil")
          if line.match?(/\s+rescue\s+/) && !line.match?(/^\s*rescue/)
            has_awareness = line.include?("# awareness rescue")

            # Check the line before for awareness comment
            if !has_awareness && idx > 0
              previous_line = lines[idx - 1]
              has_awareness = previous_line&.include?("# awareness rescue")
            end

            violations << { file: file_path, line: idx + 1, content: line.strip } unless has_awareness
          end
        end

        violations
      end

      def build_error_message(violations)
        message = <<~MSG

          ================================================================================
          RESCUE AWARENESS VIOLATION DETECTED
          ================================================================================

          Found #{violations.count} rescue block(s) without '# awareness rescue' comment.

          We do not allow rescue blocks without explicit awareness because:
          1. AI agents often generate careless exception handling
          2. Silent failures hide bugs and make debugging difficult
          3. Each rescue should be intentional and documented

          To fix this, either:
          1. Remove the rescue block if it's not truly necessary
          2. Add '# awareness rescue: <reason>' comment explaining why it's needed

          Example:
            # awareness rescue: cleanup resources even if operation fails
            rescue StandardError => e
              cleanup_resources
            end

          Violations found in:

        MSG

        violations
          .first(20)
          .each do |v|
            relative_path = v[:file].sub("#{Dir.pwd}/", "")
            message += "  #{relative_path}:#{v[:line]}\n"
            message += "    #{v[:content]}\n\n"
          end

        message += "  ... and #{violations.count - 20} more violations\n" if violations.count > 20

        message += "\n" + "=" * 80 + "\n"
        message
      end
    end
  end
end
