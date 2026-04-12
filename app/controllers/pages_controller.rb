class PagesController < ApplicationController
  def home
    @connections = []

    if current_user.ow_user_id.present?
      client = OpenWearablesClient.new
      @connections = client.get_connections(user_id: current_user.ow_user_id)
    end
  rescue OpenWearablesClient::ApiError => e
    Rails.logger.error("OW API error loading connections: #{e.message}")
    @connections = []
  end
end
