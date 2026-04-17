class WorkoutsFetcher
  DAYS = 30
  MAX_PAGES = 10
  PAGE_SIZE = 100

  def initialize(user_id:, client: OpenWearables::Client.new, today: Date.current)
    @user_id = user_id
    @client = client
    @today = today
  end

  def call
    workouts = []
    cursor = nil

    MAX_PAGES.times do
      response = @client.get_workouts(
        user_id: @user_id,
        start_date: @today - DAYS,
        end_date: @today,
        cursor: cursor,
        limit: PAGE_SIZE
      )
      workouts.concat(Array(response["data"]))
      pagination = response["pagination"] || {}
      break unless pagination["has_more"]
      cursor = pagination["next_cursor"]
      break if cursor.blank?
    end

    workouts
  end
end
