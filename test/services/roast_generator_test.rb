require "test_helper"

class RoastGeneratorTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :calls

    def initialize(response)
      @response = response
      @calls = []
    end

    def chat(parameters:)
      @calls << parameters
      raise @response if @response.is_a?(StandardError)
      @response
    end
  end

  def stats_with_workouts
    WorkoutStats.new([
      { "type" => "run", "duration_seconds" => 3600, "calories_kcal" => 400, "distance_meters" => 8000, "avg_heart_rate_bpm" => 150, "name" => "Morning Run", "start_time" => "2026-04-10T08:00:00Z" }
    ])
  end

  test "returns parsed roasts keyed by card kind" do
    client = FakeClient.new({
      "choices" => [ { "message" => { "content" => {
        "summary" => "One run? That's a warmup.",
        "most_common_type" => "Running, original.",
        "longest_workout" => "An hour? Grandma laughs.",
        "totals" => "400 calories - a cookie."
      }.to_json } } ]
    })

    roasts = RoastGenerator.new(stats_with_workouts, client: client).call

    assert_equal "One run? That's a warmup.", roasts[:summary]
    assert_equal "Running, original.", roasts[:most_common_type]
    assert_equal "An hour? Grandma laughs.", roasts[:longest_workout]
    assert_equal "400 calories - a cookie.", roasts[:totals]
  end

  test "sends gpt-4o-mini with temperature 0.9 and both messages" do
    client = FakeClient.new({
      "choices" => [ { "message" => { "content" => "{}" } } ]
    })

    RoastGenerator.new(stats_with_workouts, client: client).call

    params = client.calls.first
    assert_equal "gpt-4o-mini", params[:model]
    assert_in_delta 0.9, params[:temperature]
    roles = params[:messages].map { |m| m[:role] }
    assert_equal %w[system user], roles
    assert_match "roast comedian", params[:messages].first[:content]
  end

  test "returns empty hash when API raises" do
    client = FakeClient.new(StandardError.new("boom"))

    roasts = RoastGenerator.new(stats_with_workouts, client: client).call

    assert_equal({}, roasts)
  end

  test "returns empty hash when response is not valid JSON" do
    client = FakeClient.new({
      "choices" => [ { "message" => { "content" => "not json" } } ]
    })

    roasts = RoastGenerator.new(stats_with_workouts, client: client).call

    assert_equal({}, roasts)
  end

  test "skips calling the API when there are no workouts" do
    client = FakeClient.new({ "choices" => [] })

    roasts = RoastGenerator.new(WorkoutStats.new([]), client: client).call

    assert_equal({}, roasts)
    assert_empty client.calls
  end

  test "skips calling the API when the client is nil" do
    roasts = RoastGenerator.new(stats_with_workouts, client: nil).call
    assert_equal({}, roasts)
  end
end
