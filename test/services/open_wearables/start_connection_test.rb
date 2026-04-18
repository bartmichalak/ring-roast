require "test_helper"

module OpenWearables
  class StartConnectionTest < ActiveSupport::TestCase
    test "creates ow user when missing, stores id, then returns authorization url" do
      user = users(:anonymous)
      client = fake_client(
        create_user_response: { "id" => "ow-new-1" },
        authorize_response: { "authorization_url" => "https://provider/auth" }
      )

      url = StartConnection.new(
        user: user, provider: "oura", redirect_uri: "https://app/cb", client: client
      ).call

      assert_equal "https://provider/auth", url
      assert_equal "ow-new-1", user.reload.ow_user_id
      assert_equal 1, client.create_user_calls
      assert_equal({ provider: "oura", user_id: "ow-new-1", redirect_uri: "https://app/cb" }, client.authorize_args)
    end

    test "skips creating ow user when already connected" do
      user = users(:connected)
      client = fake_client(
        authorize_response: { "authorization_url" => "https://provider/auth" }
      )

      StartConnection.new(
        user: user, provider: "oura", redirect_uri: "https://app/cb", client: client
      ).call

      assert_equal 0, client.create_user_calls
      assert_equal "ow-user-123", client.authorize_args[:user_id]
    end

    private

    def fake_client(create_user_response: nil, authorize_response: nil)
      client = Object.new
      client.instance_variable_set(:@create_calls, 0)
      client.instance_variable_set(:@authorize_args, nil)

      client.define_singleton_method(:create_user) do |*_args|
        @create_calls += 1
        create_user_response
      end
      client.define_singleton_method(:authorize_url) do |provider:, user_id:, redirect_uri:|
        @authorize_args = { provider: provider, user_id: user_id, redirect_uri: redirect_uri }
        authorize_response
      end
      client.define_singleton_method(:create_user_calls) { @create_calls }
      client.define_singleton_method(:authorize_args) { @authorize_args }
      client
    end
  end
end
