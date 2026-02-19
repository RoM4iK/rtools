# frozen_string_literal: true

module Rtools
  class Engine < ::Rails::Engine
    # Not isolating namespace so we can inherit from main app's ApplicationController
    # and use all its helpers (current_user, root_path, etc.)
    routes do
      # Routes are mounted at /dev in the main app
      resources :performance_profiles, only: %i[index show], format: false
    end
  end
end
