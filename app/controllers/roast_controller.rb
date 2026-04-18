class RoastController < ApplicationController
  layout "roast"

  def show
    if current_user.ow_user_id.blank?
      redirect_to connections_path, alert: "Connect a wearable first to see your roast."
      return
    end

    connections = client.get_connections(user_id: current_user.ow_user_id)
    if connections.none? { |c| c["status"] == "active" }
      redirect_to connections_path, alert: "Connect a wearable first to see your roast."
      return
    end

    workouts = WorkoutsFetcher.new(user_id: current_user.ow_user_id, client: client).call
    @stats = WorkoutStats.new(workouts)
    @roasts = RoastGenerator.new(@stats).call
  rescue OpenWearables::Error => e
    redirect_to root_path, alert: "Couldn't load your workouts: #{e.message}"
  end

  private

  def client
    @client ||= OpenWearables::Client.new
  end
end
