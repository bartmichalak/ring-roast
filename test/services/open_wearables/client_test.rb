require "test_helper"

module OpenWearables
  class ClientTest < ActiveSupport::TestCase
    setup do
      @original_key = ENV["OPEN_WEARABLES_API_KEY"]
      @original_url = ENV["OPEN_WEARABLES_API_URL"]
      @original_net_http_start = Net::HTTP.method(:start)
      ENV["OPEN_WEARABLES_API_KEY"] = "test-key"
      ENV["OPEN_WEARABLES_API_URL"] = "https://ow.test"
    end

    teardown do
      ENV["OPEN_WEARABLES_API_KEY"] = @original_key
      ENV["OPEN_WEARABLES_API_URL"] = @original_url
      Net::HTTP.define_singleton_method(:start, @original_net_http_start)
    end

    test "raises when API key is missing" do
      ENV["OPEN_WEARABLES_API_KEY"] = nil
      assert_raises(OpenWearables::Error) { OpenWearables::Client.new }
    end

    test "raises when API URL is missing" do
      ENV["OPEN_WEARABLES_API_URL"] = nil
      assert_raises(OpenWearables::Error) { OpenWearables::Client.new }
    end

    test "create_user POSTs to /api/v1/users and returns parsed JSON" do
      captured = stub_net_http(status: "200", body: { id: "u-1" }.to_json)

      result = OpenWearables::Client.new.create_user

      assert_equal "u-1", result["id"]
      assert_equal "/api/v1/users", captured[:uri].path
      assert_instance_of Net::HTTP::Post, captured[:req]
      assert_equal "test-key", captured[:req]["X-Open-Wearables-API-Key"]
    end

    test "list_providers GETs /api/v1/oauth/providers" do
      captured = stub_net_http(status: "200", body: [].to_json)

      OpenWearables::Client.new.list_providers

      assert_equal "/api/v1/oauth/providers", captured[:uri].path
      assert_instance_of Net::HTTP::Get, captured[:req]
    end

    test "get_authorize_url passes user_id and redirect_uri as query params" do
      captured = stub_net_http(status: "200", body: { authorization_url: "https://p.example" }.to_json)

      OpenWearables::Client.new.get_authorize_url(
        provider: "garmin",
        user_id: "u-1",
        redirect_uri: "https://app.example/cb"
      )

      assert_equal "/api/v1/oauth/garmin/authorize", captured[:uri].path
      query = URI.decode_www_form(captured[:uri].query).to_h
      assert_equal "u-1", query["user_id"]
      assert_equal "https://app.example/cb", query["redirect_uri"]
    end

    test "get_workouts GETs events/workouts with date range and cursor" do
      captured = stub_net_http(status: "200", body: { data: [], pagination: { has_more: false } }.to_json)

      OpenWearables::Client.new.get_workouts(
        user_id: "u-1",
        start_date: "2026-03-18",
        end_date: "2026-04-17",
        cursor: "abc",
        limit: 100
      )

      assert_equal "/api/v1/users/u-1/events/workouts", captured[:uri].path
      query = URI.decode_www_form(captured[:uri].query).to_h
      assert_equal "2026-03-18", query["start_date"]
      assert_equal "2026-04-17", query["end_date"]
      assert_equal "abc", query["cursor"]
      assert_equal "100", query["limit"]
    end

    test "get_workouts omits nil params" do
      captured = stub_net_http(status: "200", body: { data: [], pagination: { has_more: false } }.to_json)

      OpenWearables::Client.new.get_workouts(user_id: "u-1")

      assert_equal "/api/v1/users/u-1/events/workouts", captured[:uri].path
      assert_nil captured[:uri].query
    end

    test "raises Error with status on non-2xx response" do
      stub_net_http(status: "500", body: "oops")

      error = assert_raises(OpenWearables::Error) { OpenWearables::Client.new.create_user }
      assert_equal 500, error.status
    end

    private

    def stub_net_http(status:, body:)
      captured = {}
      response = build_fake_response(status, body)

      Net::HTTP.define_singleton_method(:start) do |_host, _port, _opts = {}, &block|
        http = Object.new
        http.define_singleton_method(:request) do |req|
          captured[:req] = req
          captured[:uri] = req.uri
          response
        end
        block.call(http)
      end

      captured
    end

    def build_fake_response(status, body)
      klass = status.start_with?("2") ? Net::HTTPOK : Net::HTTPInternalServerError
      response = klass.new("1.1", status, "")
      response.define_singleton_method(:body) { body }
      response.define_singleton_method(:code) { status }
      response.define_singleton_method(:message) { "" }
      response
    end
  end
end
