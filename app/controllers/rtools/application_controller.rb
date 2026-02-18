# frozen_string_literal: true

# Base controller for Rtools engine
module Rtools
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :set_locale

    private

    def set_locale
      I18n.locale = :en
    end
  end
end
