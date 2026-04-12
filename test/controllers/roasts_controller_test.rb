require "test_helper"

class RoastsControllerTest < ActionDispatch::IntegrationTest
  test "redirects to connections when user has no ow_user_id" do
    get roast_path
    assert_redirected_to connections_path
  end

  test "renders successfully with workout data" do
    fake = fake_client(
      get_connections: [ { "provider" => "garmin", "status" => "active" } ],
      get_workouts: [
        {
          "id" => "w1", "type" => "running", "name" => "Morning Run",
          "start_time" => "2026-03-15T07:00:00Z", "end_time" => "2026-03-15T08:00:00Z",
          "duration_seconds" => 3600, "calories_kcal" => 400, "distance_meters" => 8000,
          "avg_heart_rate_bpm" => 145, "max_heart_rate_bpm" => 172,
          "source" => { "provider" => "garmin" }
        }
      ]
    )

    with_fake_client(fake) do
      # First authorize to get ow_user_id
      get authorize_connections_path(provider: "garmin")
      # Then view roast
      get roast_path
    end

    assert_response :success
    assert_select "div[data-controller='card-navigation']"
  end

  test "renders empty state when no workouts" do
    fake = fake_client(
      get_connections: [ { "provider" => "garmin", "status" => "active" } ],
      get_workouts: []
    )

    with_fake_client(fake) do
      get authorize_connections_path(provider: "garmin")
      get roast_path
    end

    assert_response :success
    assert_select "h2", "No Workouts Yet"
  end

  test "handles API error gracefully" do
    fake = Object.new
    fake.define_singleton_method(:get_providers) { |**_| [] }
    fake.define_singleton_method(:create_user) { |**_| { "id" => "ow-uuid" } }
    fake.define_singleton_method(:authorize_provider) { |**_| { "authorization_url" => "https://example.com", "state" => "x" } }
    fake.define_singleton_method(:get_connections) { |**_| [ { "provider" => "garmin" } ] }
    fake.define_singleton_method(:get_workouts) { |**_| raise OpenWearablesClient::ApiError.new("fail", status: 500, body: {}) }

    with_fake_client(fake) do
      get authorize_connections_path(provider: "garmin")
      get roast_path
    end

    assert_redirected_to root_path
  end

  private

  def fake_client(**methods)
    # Include defaults needed for authorize flow
    defaults = {
      create_user: { "id" => "ow-uuid" },
      authorize_provider: { "authorization_url" => "https://example.com/oauth", "state" => "x" }
    }
    client = Object.new
    defaults.merge(methods).each do |name, return_value|
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
