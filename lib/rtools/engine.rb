# frozen_string_literal: true

module Rtools
  class Engine < ::Rails::Engine
    # Don't isolate namespace - we want to inherit from main app's ApplicationController
    # to access the layout and all helpers
    routes do
      resources :performance_profiles, only: %i[index show], format: false
    end
  end
end
