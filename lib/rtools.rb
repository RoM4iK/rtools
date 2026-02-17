# frozen_string_literal: true

require_relative "rtools/version"

# Optional requires - only load if dependencies are available
begin
  require "rubocop"
  # Require the cop using the original namespace for backwards compatibility
  require_relative "rtools/rubocop/cop/custom/awareness_rescue"
rescue LoadError
  # RuboCop not available, skip cop
end

begin
  require "rails"
  require_relative "rtools/performance_profiler_middleware"
  require_relative "rtools/railtie"
rescue LoadError
  # Rails not available, skip middleware
end

require_relative "rtools/rescue_awareness_checker"

module Rtools
  # Root module for the Rtools gem
  # Contains custom developer tooling for Rails applications
end
