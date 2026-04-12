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
      with_fake_roasts do
        get authorize_connections_path(provider: "garmin")
        get roast_path
      end
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
      with_fake_roasts do
        get authorize_connections_path(provider: "garmin")
        get roast_path
      end
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
      with_fake_roasts do
        get authorize_connections_path(provider: "garmin")
        get roast_path
      end
    end

    assert_redirected_to root_path
  end

  test "renders cards without roast text when OpenAI fails" do
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

    # Stub RoastGeneratorService to return empty (simulating OpenAI failure)
    with_fake_client(fake) do
      with_fake_roasts({}) do
        get authorize_connections_path(provider: "garmin")
        get roast_path
      end
    end

    assert_response :success
    assert_select "div[data-controller='card-navigation']"
  end

  private

  def fake_client(**methods)
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

  def with_fake_roasts(roasts = { summary: "Test roast", most_common_type: "Test", longest_workout: "Test", totals: "Test" }, &block)
    original_new = RoastGeneratorService.method(:new)
    fake_service = Object.new
    fake_service.define_singleton_method(:call) { roasts }
    RoastGeneratorService.define_singleton_method(:new) { |*_| fake_service }
    block.call
  ensure
    RoastGeneratorService.define_singleton_method(:new, original_new)
  end
end
