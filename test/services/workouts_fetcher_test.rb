require "test_helper"

class WorkoutsFetcherTest < ActiveSupport::TestCase
  class FakeClient
    attr_reader :calls

    def initialize(pages)
      @pages = pages
      @calls = []
    end

    def get_workouts(**params)
      @calls << params
      @pages.shift || { "data" => [], "pagination" => { "has_more" => false } }
    end
  end

  test "requests the last 30 days" do
    client = FakeClient.new([
      { "data" => [ { "id" => "a" } ], "pagination" => { "has_more" => false } }
    ])

    today = Date.new(2026, 4, 17)
    WorkoutsFetcher.new(user_id: "u-1", client: client, today: today).call

    assert_equal today - 30, client.calls.first[:start_date]
    assert_equal today, client.calls.first[:end_date]
  end

  test "follows cursor until has_more is false" do
    client = FakeClient.new([
      { "data" => [ { "id" => "a" } ], "pagination" => { "has_more" => true, "next_cursor" => "c1" } },
      { "data" => [ { "id" => "b" } ], "pagination" => { "has_more" => true, "next_cursor" => "c2" } },
      { "data" => [ { "id" => "c" } ], "pagination" => { "has_more" => false } }
    ])

    workouts = WorkoutsFetcher.new(user_id: "u-1", client: client).call

    assert_equal %w[a b c], workouts.map { |w| w["id"] }
    assert_equal [ nil, "c1", "c2" ], client.calls.map { |c| c[:cursor] }
  end

  test "stops after MAX_PAGES even when has_more stays true" do
    client = FakeClient.new(Array.new(20) do |i|
      { "data" => [ { "id" => i.to_s } ], "pagination" => { "has_more" => true, "next_cursor" => "c#{i}" } }
    end)

    workouts = WorkoutsFetcher.new(user_id: "u-1", client: client).call

    assert_equal WorkoutsFetcher::MAX_PAGES, client.calls.size
    assert_equal WorkoutsFetcher::MAX_PAGES, workouts.size
  end
end
