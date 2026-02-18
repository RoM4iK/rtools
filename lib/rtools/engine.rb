# frozen_string_literal: true

module Rtools
  class Engine < ::Rails::Engine
    isolate_namespace Rtools

    # Add app/ directories to autoload paths once the engine is initialized
    initializer "rtools.autoload_paths", before: :eager_load do
      config.autoload_paths += %W[
        #{root}/app/controllers
        #{root}/app/services
        #{root}/app/helpers
      ]
    end

    routes do
      resources :performance_profiles, only: %i[index show], format: false
    end
  end
end
