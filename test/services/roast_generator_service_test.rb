require "test_helper"

class RoastGeneratorServiceTest < ActiveSupport::TestCase
  test "returns empty hash when stats are empty" do
    result = RoastGeneratorService.new({ empty: true }).call
    assert_equal({}, result)
  end

  test "returns roasts from OpenAI response" do
    fake_response = {
      "choices" => [ {
        "message" => {
          "content" => {
            summary: "You call that working out?",
            most_common_type: "Running again? How original.",
            longest_workout: "2 hours? That's a nap, not a workout.",
            totals: "800 calories? That's one burger."
          }.to_json
        }
      } ]
    }

    fake_client = Object.new
    fake_client.define_singleton_method(:chat) { |**_| fake_response }

    result = RoastGeneratorService.new(build_stats, client: fake_client).call
    assert_equal "You call that working out?", result[:summary]
    assert_equal "Running again? How original.", result[:most_common_type]
    assert_equal "2 hours? That's a nap, not a workout.", result[:longest_workout]
    assert_equal "800 calories? That's one burger.", result[:totals]
  end

  test "returns empty hash on OpenAI error" do
    fake_client = Object.new
    fake_client.define_singleton_method(:chat) { |**_| raise StandardError, "API down" }

    result = RoastGeneratorService.new(build_stats, client: fake_client).call
    assert_equal({}, result)
  end

  test "returns empty hash on invalid JSON response" do
    fake_response = {
      "choices" => [ { "message" => { "content" => "not valid json" } } ]
    }

    fake_client = Object.new
    fake_client.define_singleton_method(:chat) { |**_| fake_response }

    result = RoastGeneratorService.new(build_stats, client: fake_client).call
    assert_equal({}, result)
  end

  private

  def build_stats
    {
      empty: false,
      summary: { total_count: 5, total_duration_seconds: 18000, total_duration_formatted: "5h 0m", period_days: 30 },
      most_common_type: { type: "running", count: 3, percentage: 60, type_breakdown: { "running" => 3, "cycling" => 2 } },
      longest_workout: { name: "Long Run", type: "running", duration_seconds: 7200, duration_formatted: "2h 0m", date: "March 15", calories_kcal: 600, avg_heart_rate_bpm: 155 },
      totals: { total_calories_kcal: 2500, total_distance_meters: 40000, total_distance_km: 40.0, avg_heart_rate_bpm: 145 }
    }
  end
end
