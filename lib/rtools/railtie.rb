# frozen_string_literal: true

module Rtools
  class Railtie < ::Rails::Railtie
    railtie_name :rtools

    # Register the performance profiler middleware BEFORE middleware stack is built
    # This must run before :build_middleware_stack to avoid frozen array errors
    initializer "rtools.performance_profiler", before: :build_middleware_stack do |app|
      next unless performance_profiler_enabled?

      app.middleware.use Rtools::PerformanceProfilerMiddleware
    end

    # Mount the engine routes after routes are initialized
    initializer "rtools.mount_engine", after: :add_routing_paths do |app|
      next unless Rails.env.development?
      next unless performance_profiler_enabled?

      app.routes.append do
        mount Rtools::Engine, at: "/dev"
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
