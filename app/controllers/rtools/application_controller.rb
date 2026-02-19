# frozen_string_literal: true

# Base controller for Rtools engine - isolated namespace for development tools
module Rtools
  class ApplicationController < ActionController::Base
    # Development tools don't require authentication
  end
end
