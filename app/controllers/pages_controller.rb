class PagesController < ApplicationController
  def home
    @connections = OpenWearables::ListUserConnections.new(user: current_user).call
  rescue OpenWearables::Error => error
    Rails.logger.error("Open Wearables error loading connections: #{error.message}")
    @connections = []
  end
end
