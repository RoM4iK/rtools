# frozen_string_literal: true

module Rtools
  class Engine < ::Rails::Engine
    isolate_namespace Rtools

    # Only mount in development
    config.before_initialize do
      next unless Rails.env.development?

      # Mount the engine at /dev/performance_profiles
      # This must be done at app initialization time
    end
  end
end
