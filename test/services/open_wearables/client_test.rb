require "test_helper"

module OpenWearables
  class ClientTest < ActiveSupport::TestCase
    setup do
      @client = Client.new(api_key: "test-key", api_url: "https://api.example.com")
    end

    test "create_user POSTs to /api/v1/users with api key header" do
      captured = stub_perform(@client, status: 201, body: { "id" => "ow-1" })
      result = @client.create_user(email: "a@b.com")

      assert_equal "ow-1", result["id"]
      assert_equal "POST", captured[:method]
      assert_equal "https://api.example.com/api/v1/users", captured[:url]
      assert_equal "test-key", captured[:request][Client::API_KEY_HEADER]
      assert_equal({ email: "a@b.com" }, JSON.parse(captured[:body], symbolize_names: true))
    end

    test "list_providers GETs providers with cloud_only and enabled_only" do
      captured = stub_perform(@client, status: 200, body: [ { "provider" => "garmin" } ])
      result = @client.list_providers

      assert_equal "garmin", result.first["provider"]
      assert_equal "GET", captured[:method]
      uri = URI.parse(captured[:url])
      assert_equal "/api/v1/oauth/providers", uri.path
      assert_includes uri.query, "cloud_only=true"
      assert_includes uri.query, "enabled_only=true"
    end

    test "authorize_url passes user_id and redirect_uri" do
      captured = stub_perform(@client, status: 200, body: { "authorization_url" => "https://provider/oauth" })
      result = @client.authorize_url(provider: "oura", user_id: "u1", redirect_uri: "https://app/cb")

      assert_equal "https://provider/oauth", result["authorization_url"]
      uri = URI.parse(captured[:url])
      assert_equal "/api/v1/oauth/oura/authorize", uri.path
      params = URI.decode_www_form(uri.query).to_h
      assert_equal "u1", params["user_id"]
      assert_equal "https://app/cb", params["redirect_uri"]
    end

    test "connections GETs /api/v1/users/{id}/connections" do
      captured = stub_perform(@client, status: 200, body: [])
      @client.connections(user_id: "u1")

      assert_equal "/api/v1/users/u1/connections", URI.parse(captured[:url]).path
    end

    test "non-2xx response raises Error with status and body" do
      stub_perform(@client, status: 500, body: { "error" => "boom" })

      error = assert_raises(Error) { @client.list_providers }
      assert_equal 500, error.status
      assert_equal "boom", error.body["error"]
    end

    private

    def stub_perform(client, status:, body:)
      captured = {}
      response_body = body.is_a?(String) ? body : body.to_json
      fake_response = FakeResponse.new(status.to_s, response_body)

      client.define_singleton_method(:perform) do |req|
        req[Client::API_KEY_HEADER] = @api_key
        req["Accept"] = "application/json"
        captured[:method] = req.method
        captured[:url] = req.uri.to_s
        captured[:request] = req
        captured[:body] = req.body
        send(:handle_response, fake_response)
      end
      captured
    end

    class FakeResponse
      attr_reader :code, :body

      def initialize(code, body)
        @code = code
        @body = body
      end
    end
  end
end
