# frozen_string_literal: true

Rtools::Engine.routes.draw do
  resources :performance_profiles, only: %i[index show], format: false
end
