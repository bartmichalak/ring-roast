class ConnectionsController < ApplicationController
  def index
    client = OpenWearablesClient.new
    @providers = client.get_providers(enabled_only: true, cloud_only: true)
  rescue OpenWearablesClient::ApiError => e
    Rails.logger.error("OW API error loading providers: #{e.message}")
    flash.now[:alert] = "Could not load providers. Please try again."
    @providers = []
  end

  def authorize
    client = OpenWearablesClient.new
    ensure_ow_user!(client)

    result = client.authorize_provider(
      provider: params[:provider],
      user_id: current_user.ow_user_id,
      redirect_uri: callback_connections_url
    )

    redirect_to result["authorization_url"], allow_other_host: true
  rescue OpenWearablesClient::ApiError => e
    Rails.logger.error("OW API error in authorize: #{e.message}")
    flash[:alert] = "Could not connect to #{params[:provider]}. Please try again."
    redirect_to connections_path
  end

  def callback
    if current_user.ow_user_id.present?
      client = OpenWearablesClient.new
      connections = client.get_connections(user_id: current_user.ow_user_id)

      if connections.any?
        flash[:notice] = "Successfully connected your wearable!"
      else
        flash[:alert] = "Connection could not be verified. Please try again."
      end
    end

    redirect_to root_path
  rescue OpenWearablesClient::ApiError => e
    Rails.logger.error("OW API error in callback: #{e.message}")
    flash[:alert] = "Something went wrong. Please try again."
    redirect_to root_path
  end

  private

  def ensure_ow_user!(client)
    return if current_user.ow_user_id.present?

    result = client.create_user(external_user_id: current_user.session_token)
    current_user.update!(ow_user_id: result["id"])
  end
end
