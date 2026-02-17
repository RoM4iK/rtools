# frozen_string_literal: true

module Rtools
  class Railtie < ::Rails::Railtie
    railtie_name :rtools

    # Register the performance profiler middleware in development
    initializer "rtools.performance_profiler" do |app|
      if performance_profiler_enabled?
        app.middleware.insert_before ActionDispatch::Static, Rtools::PerformanceProfilerMiddleware
      end
    end

    # Configuration for the gem
    config.rtools = ActiveSupport::OrderedOptions.new
    config.rtools.performance_profiler = ActiveSupport::OrderedOptions.new
    config.rtools.performance_profiler.enabled = true
    config.rtools.performance_profiler.storage_path = nil # Uses default: Rails.root/tmp/performance_profiles
    config.rtools.performance_profiler.skip_paths = []

    # Check if performance profiler is enabled
    def performance_profiler_enabled?
      return false unless defined?(Rails)
      return false unless Rails.configuration.rtools.respond_to?(:performance_profiler)

      Rails.configuration.rtools.performance_profiler.enabled && Rails.env.development?
    end
  end
end
