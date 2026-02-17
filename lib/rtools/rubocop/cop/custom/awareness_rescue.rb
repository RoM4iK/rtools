# frozen_string_literal: true

if defined?(Rails) && !Rails.env.test?
  module Rubocop
    module Cop
      module Custom
        # This cop is disabled in production environment.
        class AwarenessRescue
        end
      end
    end
  end

  return
end

module Rubocop
  module Cop
    module Custom
      # This cop ensures that rescue blocks include an "awareness rescue" comment
      # to indicate intentional exception handling.
      #
      # @example
      #   # bad
      #   def foo
      #     do_something
      #   rescue StandardError => e
      #     handle_error(e)
      #   end
      #
      #   # bad (inline)
      #   value = parse_date(str) rescue nil
      #
      #   # good
      #   def foo
      #     do_something
      #   rescue StandardError => e # awareness rescue: handle expected errors during processing
      #     handle_error(e)
      #   end
      #
      #   # good (inline)
      #   # awareness rescue: invalid dates should return nil for graceful fallback
      #   value = parse_date(str) rescue nil
      #
      class AwarenessRescue < ::RuboCop::Cop::Base
        MSG = "Rescue blocks must include an '# awareness rescue' comment explaining why exception handling is intentional and necessary."

        def on_resbody(node)
          # Check if there's an awareness rescue comment on the rescue line or the line before
          rescue_line = node.loc.keyword.line
          source_line = processed_source.lines[rescue_line - 1]

          # Check the rescue line itself
          return if source_line&.include?('# awareness rescue')

          # Check the line before the rescue
          if rescue_line > 1
            previous_line = processed_source.lines[rescue_line - 2]
            return if previous_line&.include?('# awareness rescue')
          end

          add_offense(node.loc.keyword)
        end
      end
    end
  end
end
