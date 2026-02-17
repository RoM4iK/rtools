# frozen_string_literal: true

module Rtools
  class PerformanceProfilerMiddleware
    THREAD_KEY = :_dev_performance_profiler_queries

    def initialize(app)
      @app = app
      # Subscribe once globally
      ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, start, finish, _id, payload|
        if (queries = Thread.current[THREAD_KEY])
          unless payload[:name] == "SCHEMA" || payload[:name] == "CACHE"
            duration_ms = (finish - start) * 1000
            queries << { sql: payload[:sql], duration: duration_ms.round(2) }
          end
        end
      end
    end

    def call(env)
      return @app.call(env) unless enabled?

      request = Rack::Request.new(env)
      return @app.call(env) if skip_profiling?(request.path)

      Thread.current[THREAD_KEY] = []
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      begin
        status, headers, response = @app.call(env)
      rescue Exception => e
        # -------------------------------------------------------------
        # THE INVISIBILITY CLOAK
        # -------------------------------------------------------------
        # 1. Get the current backtrace
        # 2. Reject any lines that point to THIS file
        # 3. Set the backtrace back on the exception
        # 4. Re-raise
        # -------------------------------------------------------------
        cleaned_trace = e.backtrace.reject { |line| line.include?(__FILE__) }
        e.set_backtrace(cleaned_trace)
        raise e
      end

      # Logic only runs if no error occurred
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      record_metrics(env, start_time, end_time)

      [status, headers, response]
    ensure
      Thread.current[THREAD_KEY] = nil
    end

    private

    def enabled?
      if defined?(Rails)
        Rails.env.development?
      else
        ENV["RACK_ENV"] == "development" || ENV["RAILS_ENV"] == "development"
      end
    end

    def record_metrics(env, start_time, end_time)
      queries = Thread.current[THREAD_KEY] || []
      total_time = ((end_time - start_time) * 1000).round(2)
      sql_time = queries.sum { |q| q[:duration] }

      profile_data = {
        url: env["PATH_INFO"],
        method: env["REQUEST_METHOD"],
        total_time: total_time,
        sql_time: sql_time.round(2),
        sql_queries: queries,
        timestamp: Time.now.iso8601(3),
        request_id: env["action_dispatch.request_id"]
      }

      store_profile(profile_data)
    rescue StandardError => e
      # awareness rescue: metrics recording failures should not break user requests
      logger.error "Profiler Error: #{e.message}" if defined?(logger)
    end

    def skip_profiling?(path)
      path.start_with?("/assets", "/rails/active_storage", "/up", "/dev/performance_profiles") ||
        path.match?(/\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/i)
    end

    def store_profile(profile_data)
      storage_dir = storage_path
      FileUtils.mkdir_p(storage_dir)
      slug = profile_data[:url].gsub("/", "_").gsub(/^_/, "").presence || "root"
      file_path = File.join(storage_dir, "#{slug}.json")

      profiles = File.exist?(file_path) ? JSON.parse(File.read(file_path), symbolize_names: true) : []
      profiles << profile_data
      profiles = profiles.sort_by { |p| p[:timestamp] }.reverse.take(5)

      File.write(file_path, JSON.pretty_generate(profiles))
    end

    def storage_path
      if defined?(Rails) && Rails.respond_to?(:root)
        Rails.root.join("tmp", "performance_profiles")
      else
        Pathname.new(ENV.fetch("RTOOLS_STORAGE_PATH", "tmp/performance_profiles"))
      end
    end

    def logger
      defined?(Rails) ? Rails.logger : Logger.new($stderr)
    end
  end
end
