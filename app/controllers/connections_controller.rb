class ConnectionsController < ApplicationController
  rescue_from OpenWearables::Error, with: :handle_api_error

  def index
    @providers = OpenWearables::ListProviders.new.call
  end

  def create
    authorization_url = OpenWearables::StartConnection.new(
      user: current_user,
      provider: params[:provider],
      redirect_uri: connections_callback_url
    ).call

    redirect_to authorization_url, allow_other_host: true
  end

  def callback
    connections = OpenWearables::ListUserConnections.new(user: current_user).call

    if connections.any? { |c| c["status"] == "active" }
      redirect_to root_path, notice: "Wearable connected successfully."
    else
      redirect_to root_path, alert: "We couldn't verify your wearable connection. Please try again."
    end
  end

  private

  def handle_api_error(error)
    Rails.logger.error("Open Wearables error: #{error.message} status=#{error.status} body=#{error.body}")
    redirect_to connections_path, alert: "Something went wrong talking to Open Wearables. Please try again."
  end
end
