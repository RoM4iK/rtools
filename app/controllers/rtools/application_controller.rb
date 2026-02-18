# frozen_string_literal: true

# Base controller for Rtools engine
module Rtools
  class ApplicationController < ActionController::Base
    # Don't inherit any behavior from the main app
    protect_from_forgery with: :exception

    before_action :set_locale

    # Helper methods for the main app's layout
    helper_method :current_user, :browser_device, :impersonating?, :impersonating_admin

    def current_user
      nil
    end

    def browser_device
      nil
    end

    def impersonating?
      false
    end

    def impersonating_admin
      nil
    end

    private

    def set_locale
      I18n.locale = :en
    end
  end
end
