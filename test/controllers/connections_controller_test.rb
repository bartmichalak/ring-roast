require "test_helper"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    fake = fake_client(
      get_providers: [{ "provider" => "garmin", "name" => "Garmin", "icon_url" => "https://example.com/garmin.png" }]
    )
    with_fake_client(fake) { get connections_path }

    assert_response :success
    assert_select "span", "Garmin"
  end

  test "index handles API error gracefully" do
    fake = Object.new
    fake.define_singleton_method(:get_providers) { |**_| raise OpenWearablesClient::ApiError.new("fail", status: 500, body: {}) }

    with_fake_client(fake) { get connections_path }

    assert_response :success
  end

  test "authorize redirects to OAuth URL" do
    fake = fake_client(
      create_user: { "id" => "ow-uuid-from-api" },
      authorize_provider: { "authorization_url" => "https://garmin.com/oauth?state=abc", "state" => "abc" }
    )

    with_fake_client(fake) do
      get authorize_connections_path(provider: "garmin")
    end

    assert_response :redirect
    assert_redirected_to "https://garmin.com/oauth?state=abc"
  end

  test "authorize creates OW user if needed" do
    fake = fake_client(
      create_user: { "id" => "new-ow-uuid" },
      authorize_provider: { "authorization_url" => "https://garmin.com/oauth", "state" => "abc" }
    )

    with_fake_client(fake) do
      get authorize_connections_path(provider: "garmin")
    end

    assert_response :redirect
    # The auto-created user should now have an ow_user_id
    user = User.find(session[:user_id])
    assert_equal "new-ow-uuid", user.ow_user_id
  end

  test "callback redirects to root with notice on success" do
    fake = fake_client(
      create_user: { "id" => "ow-uuid" },
      authorize_provider: { "authorization_url" => "https://example.com/oauth", "state" => "x" },
      get_connections: [{ "provider" => "garmin", "status" => "active" }]
    )

    with_fake_client(fake) do
      # First trigger authorize to create the OW user
      get authorize_connections_path(provider: "garmin")
      # Then hit callback
      get callback_connections_path
    end

    assert_redirected_to root_path
    assert_equal "Successfully connected your wearable!", flash[:notice]
  end

  test "callback redirects to root with alert when no connections" do
    fake = fake_client(
      create_user: { "id" => "ow-uuid" },
      authorize_provider: { "authorization_url" => "https://example.com/oauth", "state" => "x" },
      get_connections: []
    )

    with_fake_client(fake) do
      get authorize_connections_path(provider: "garmin")
      get callback_connections_path
    end

    assert_redirected_to root_path
    assert_equal "Connection could not be verified. Please try again.", flash[:alert]
  end

  private

  def fake_client(**methods)
    client = Object.new
    methods.each do |name, return_value|
      client.define_singleton_method(name) { |**_| return_value }
    end
    client
  end

  def with_fake_client(fake, &block)
    original_new = OpenWearablesClient.method(:new)
    OpenWearablesClient.define_singleton_method(:new) { |**_| fake }
    block.call
  ensure
    OpenWearablesClient.define_singleton_method(:new, original_new)
  end
end
