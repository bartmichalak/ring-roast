class RoastsController < ApplicationController
  layout "roast"

  def show
    unless current_user.ow_user_id.present?
      redirect_to connections_path, alert: "Connect a wearable first to get roasted!"
      return
    end

    client = OpenWearablesClient.new
    end_date = Date.current
    start_date = end_date - WorkoutStatsService::PERIOD_DAYS.days

    workouts = client.get_workouts(
      user_id: current_user.ow_user_id,
      start_date: start_date.to_s,
      end_date: end_date.to_s
    )

    @stats = WorkoutStatsService.new(workouts).call
    @roasts = RoastGeneratorService.new(@stats).call
    @colors = CardColorService.colors(count: 4)
  rescue OpenWearablesClient::ApiError => e
    Rails.logger.error("OW API error loading workouts: #{e.message}")
    redirect_to root_path, alert: "Could not load your workout data. Please try again."
  end
end
