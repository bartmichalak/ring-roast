require "test_helper"

class WorkoutStatsServiceTest < ActiveSupport::TestCase
  test "returns empty stats when no workouts" do
    result = WorkoutStatsService.new([]).call
    assert result[:empty]
  end

  test "calculates total count and duration" do
    workouts = [
      build_workout(duration_seconds: 3600),
      build_workout(duration_seconds: 1800)
    ]
    result = WorkoutStatsService.new(workouts).call
    assert_equal 2, result[:summary][:total_count]
    assert_equal 5400, result[:summary][:total_duration_seconds]
    assert_equal "1h 30m", result[:summary][:total_duration_formatted]
  end

  test "finds most common workout type" do
    workouts = [
      build_workout(type: "running"),
      build_workout(type: "running"),
      build_workout(type: "cycling")
    ]
    result = WorkoutStatsService.new(workouts).call
    assert_equal "running", result[:most_common_type][:type]
    assert_equal 2, result[:most_common_type][:count]
    assert_equal 67, result[:most_common_type][:percentage]
  end

  test "finds longest workout" do
    workouts = [
      build_workout(duration_seconds: 1800, name: "Short Run"),
      build_workout(duration_seconds: 7200, name: "Long Ride")
    ]
    result = WorkoutStatsService.new(workouts).call
    assert_equal "Long Ride", result[:longest_workout][:name]
    assert_equal 7200, result[:longest_workout][:duration_seconds]
    assert_equal "2h 0m", result[:longest_workout][:duration_formatted]
  end

  test "sums calories and distance handling nils" do
    workouts = [
      build_workout(calories_kcal: 500, distance_meters: 10000),
      build_workout(calories_kcal: nil, distance_meters: 5000),
      build_workout(calories_kcal: 300, distance_meters: nil)
    ]
    result = WorkoutStatsService.new(workouts).call
    assert_equal 800, result[:totals][:total_calories_kcal]
    assert_equal 15000, result[:totals][:total_distance_meters]
    assert_in_delta 15.0, result[:totals][:total_distance_km], 0.01
  end

  test "formats duration as minutes only when under an hour" do
    workouts = [ build_workout(duration_seconds: 1500) ]
    result = WorkoutStatsService.new(workouts).call
    assert_equal "25m", result[:summary][:total_duration_formatted]
  end

  test "uses type as name when name is nil" do
    workouts = [ build_workout(name: nil, type: "cycling") ]
    result = WorkoutStatsService.new(workouts).call
    assert_equal "cycling", result[:longest_workout][:name]
  end

  private

  def build_workout(overrides = {})
    {
      "id" => SecureRandom.uuid,
      "type" => "running",
      "name" => "Morning Run",
      "start_time" => "2026-03-15T07:00:00Z",
      "end_time" => "2026-03-15T08:00:00Z",
      "duration_seconds" => 3600,
      "calories_kcal" => 400,
      "distance_meters" => 8000,
      "avg_heart_rate_bpm" => 145,
      "max_heart_rate_bpm" => 172,
      "source" => { "provider" => "garmin", "device" => "Forerunner 265" }
    }.merge(overrides.transform_keys(&:to_s))
  end
end
