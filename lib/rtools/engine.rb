# frozen_string_literal: true

module Rtools
  class Engine < ::Rails::Engine
    routes do
      scope path: "/dev" do
        resources :performance_profiles, only: %i[index show], format: false
      end
    end
  end
end
