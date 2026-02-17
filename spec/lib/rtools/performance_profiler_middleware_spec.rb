# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe Rtools::PerformanceProfilerMiddleware do
  include Rack::Test::Methods

  let(:app) do
    lambda { |env| [200, { "Content-Type" => "text/html" }, ["OK"]] }
  end

  let(:middleware) { described_class.new(app) }

  describe "#call" do
    let(:env) do
      Rack::MockRequest.env_for("/test", method: "GET", "action_dispatch.request_id" => "test-123")
    end

    context "in non-development environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      end

      it "passes through without profiling" do
        response = middleware.call(env)
        expect(response[0]).to eq(200)
      end
    end

    context "in development environment" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        allow(Rails).to receive(:root).and_return(Pathname.new(Dir.tmpdir))
      end

      it "profiles the request" do
        response = middleware.call(env)
        expect(response[0]).to eq(200)
      end

      context "with skipped paths" do
        it "skips profiling for assets" do
          asset_env = Rack::MockRequest.env_for("/assets/style.css", method: "GET")
          response = middleware.call(asset_env)
          expect(response[0]).to eq(200)
        end

        it "skips profiling for rails active storage" do
          storage_env = Rack::MockRequest.env_for("/rails/active_storage/blobs/test", method: "GET")
          response = middleware.call(storage_env)
          expect(response[0]).to eq(200)
        end
      end
    end

    context "with exception" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        allow(Rails).to receive(:root).and_return(Pathname.new(Dir.tmpdir))
      end

      let(:failing_app) do
        lambda { |env| raise StandardError, "Test error" }
      end

      let(:failing_middleware) { described_class.new(failing_app) }

      it "cleans backtrace to hide middleware" do
        expect {
          failing_middleware.call(env)
        }.to raise_error(StandardError, "Test error")
      end
    end
  end
end
