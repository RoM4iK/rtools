# frozen_string_literal: true

# Controller for displaying performance profiles (development only)
module Rtools
  class PerformanceProfilesController < ApplicationController
    layout "application"

    # Skip authentication in development for easier access
    skip_before_action :authenticate_user!, if: -> { Rails.env.development? && respond_to?(:authenticate_user!) }
    skip_before_action :check_user_verification, if: -> { Rails.env.development? && respond_to?(:check_user_verification) }

    before_action :ensure_development_environment

    def index
      result = PerformanceProfileResultsService.call

      if result.success?
        @pages = result.value![:pages] || []
        @message = result.value![:message]
      else
        flash.now[:alert] = result.failure
        @pages = []
      end

      # Apply sorting
      @pages =
        case params[:sort]
        when "url"
          @pages.sort_by { |p| p[:url] }
        when "count"
          @pages.sort_by { |p| -p[:profile_count] }
        when "mean_asc"
          @pages.sort_by { |p| p[:mean_load_time] }
        when "sql_time"
          @pages.sort_by { |p| -p[:mean_sql_time] }
        else
          # Default: sort by mean load time descending (slowest first)
          @pages.sort_by { |p| -p[:mean_load_time] }
        end
    end

    def show
      # Force HTML format for this controller
      request.format = :html

      result = PerformanceProfileResultsService.call(page_slug: params[:id])

      if result.success?
        @page_slug = result.value![:page_slug]
        @url = result.value![:url]
        @profiles = result.value![:profiles] || []
        @profile_count = result.value![:profile_count]
        @message = result.value![:message]
      else
        flash.now[:alert] = result.failure
        @page_slug = params[:id]
        @profiles = []
      end
    end

    private

    def ensure_development_environment
      render plain: "Not Found", status: :not_found unless Rails.env.development?
    end
  end
end
