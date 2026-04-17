class ConnectionsController < ApplicationController
  def index
    providers = client.list_providers
    @providers = providers
      .select { |p| p["has_cloud_api"] && p["is_enabled"] }
      .map { |p| p.merge("icon_url" => absolute_icon_url(p["icon_url"])) }
  rescue OpenWearables::Error => e
    redirect_to root_path, alert: "Couldn't load providers: #{e.message}"
  end

  def create
    ensure_ow_user!
    response = client.get_authorize_url(
      provider: params[:provider],
      user_id: current_user.ow_user_id,
      redirect_uri: connections_callback_url
    )
    redirect_to response["authorization_url"], allow_other_host: true
  rescue OpenWearables::Error => e
    redirect_to connections_path, alert: "Couldn't start connection: #{e.message}"
  end

  def callback
    if current_user.ow_user_id.blank?
      redirect_to root_path, alert: "No Open Wearables user linked to this session."
      return
    end

    connections = client.get_connections(user_id: current_user.ow_user_id)
    if connections.any? { |c| c["status"] == "active" }
      redirect_to root_path, notice: "Wearable connected!"
    else
      redirect_to root_path, alert: "Connection wasn't completed."
    end
  rescue OpenWearables::Error => e
    redirect_to root_path, alert: "Couldn't verify connection: #{e.message}"
  end

  private

  def client
    @client ||= OpenWearables::Client.new
  end

  def ensure_ow_user!
    return if current_user.ow_user_id.present?
    ow_user = client.create_user(first_name: current_user.name)
    current_user.update!(ow_user_id: ow_user.fetch("id"))
  end

  def absolute_icon_url(path)
    return nil if path.blank?
    return path if path.start_with?("http://", "https://")
    "#{client.api_base_url}#{path}"
  end
end
