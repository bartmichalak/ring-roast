require "test_helper"

class WorkoutStatsTest < ActiveSupport::TestCase
  test "returns no cards when there are no workouts" do
    stats = WorkoutStats.new([])
    assert_not stats.any?
    assert_empty stats.cards
  end

  test "summary card counts workouts and totals duration" do
    cards = WorkoutStats.new([
      { "type" => "run", "duration_seconds" => 3600 },
      { "type" => "run", "duration_seconds" => 1800 }
    ]).cards

    summary = cards.find { |c| c[:kind] == :summary }
    assert_equal "2", summary[:value]
    assert_equal "workouts", summary[:unit]
    assert_match "1h 30m", summary[:detail]
  end

  test "top type card picks most common type with percentage" do
    cards = WorkoutStats.new([
      { "type" => "run", "duration_seconds" => 600 },
      { "type" => "run", "duration_seconds" => 600 },
      { "type" => "cycling", "duration_seconds" => 600 },
      { "type" => "run", "duration_seconds" => 600 }
    ]).cards

    top = cards.find { |c| c[:kind] == :top_type }
    assert_equal "Run", top[:value]
    assert_match "3×", top[:detail]
    assert_match "75%", top[:detail]
  end

  test "longest session card uses the max duration workout with name and date" do
    cards = WorkoutStats.new([
      { "type" => "run", "duration_seconds" => 600, "start_time" => "2026-04-10T08:00:00Z" },
      { "type" => "run", "name" => "Big Hike", "duration_seconds" => 7200, "start_time" => "2026-04-12T08:00:00Z" }
    ]).cards

    longest = cards.find { |c| c[:kind] == :longest }
    assert_equal "2h 0m", longest[:value]
    assert_match "Big Hike", longest[:detail]
    assert_match "Apr 12", longest[:detail]
  end

  test "totals skip nulls instead of counting as zero" do
    cards = WorkoutStats.new([
      { "type" => "run", "duration_seconds" => 600, "calories_kcal" => 200, "distance_meters" => 5000, "avg_heart_rate_bpm" => 140 },
      { "type" => "run", "duration_seconds" => 600, "calories_kcal" => nil, "distance_meters" => nil, "avg_heart_rate_bpm" => nil },
      { "type" => "run", "duration_seconds" => 600, "calories_kcal" => 100, "distance_meters" => 3000, "avg_heart_rate_bpm" => 160 }
    ]).cards

    totals = cards.find { |c| c[:kind] == :totals }
    assert_equal "300", totals[:value]
    assert_match "8.0 km", totals[:detail]
    assert_match "150 bpm", totals[:detail]
  end

  test "top type card uses placeholder when every workout is missing a type" do
    cards = WorkoutStats.new([
      { "type" => nil, "duration_seconds" => 600 }
    ]).cards

    top = cards.find { |c| c[:kind] == :top_type }
    assert_equal "None yet", top[:value]
  end
end
