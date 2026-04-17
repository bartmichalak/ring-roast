class PagesController < ApplicationController
  def home
    @connections = load_connections
  end

  private

  def load_connections
    return [] if current_user.ow_user_id.blank?

    OpenWearables::Client.new.get_connections(user_id: current_user.ow_user_id)
  rescue OpenWearables::Error => e
    flash.now[:alert] = "Couldn't load connections: #{e.message}"
    []
  end
end
