# frozen_string_literal: true

module Rtools
  class Engine < ::Rails::Engine
    isolate_namespace Rtools

    # Explicitly add app/ to autoload paths
    config.autoload_paths += %W[
      #{root}/app/controllers
      #{root}/app/services
      #{root}/app/helpers
    ]

    routes do
      resources :performance_profiles, only: %i[index show], format: false
    end
  end
end
