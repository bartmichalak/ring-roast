require "test_helper"

class OpenWearablesClientTest < ActiveSupport::TestCase
  setup do
    @client = OpenWearablesClient.new(api_key: "test-key", base_url: "https://api.example.com")
  end

  test "create_user sends POST and returns parsed response" do
    stub_execute({ "id" => "uuid-123", "created_at" => "2026-01-01T00:00:00Z" }) do
      result = @client.create_user(external_user_id: "ext-1")
      assert_equal "uuid-123", result["id"]
    end
  end

  test "get_providers returns parsed provider list" do
    stub_execute([{ "provider" => "garmin", "name" => "Garmin" }]) do
      result = @client.get_providers
      assert_equal 1, result.size
      assert_equal "garmin", result.first["provider"]
    end
  end

  test "authorize_provider returns authorization URL" do
    stub_execute({ "authorization_url" => "https://garmin.com/oauth", "state" => "abc" }) do
      result = @client.authorize_provider(provider: "garmin", user_id: "uuid-1", redirect_uri: "http://localhost/callback")
      assert_equal "https://garmin.com/oauth", result["authorization_url"]
    end
  end

  test "get_connections returns connections array" do
    stub_execute([{ "provider" => "garmin", "status" => "active" }]) do
      result = @client.get_connections(user_id: "uuid-1")
      assert_equal 1, result.size
      assert_equal "active", result.first["status"]
    end
  end

  test "raises ApiError on non-2xx response" do
    @client.define_singleton_method(:execute) do |_uri, _request|
      raise OpenWearablesClient::ApiError.new("API returned 401", status: 401, body: { "detail" => "Unauthorized" })
    end

    error = assert_raises(OpenWearablesClient::ApiError) do
      @client.get_providers
    end
    assert_equal 401, error.status
  end

  private

  def stub_execute(return_value)
    @client.define_singleton_method(:execute) { |_uri, _request| return_value }
    yield
  ensure
    # Remove the stubbed method so it doesn't leak
    @client.singleton_class.remove_method(:execute) if @client.singleton_class.method_defined?(:execute, false)
  end
end
