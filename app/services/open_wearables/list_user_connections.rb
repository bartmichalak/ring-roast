module OpenWearables
  class ListUserConnections
    def initialize(user:, client: Client.new)
      @user = user
      @client = client
    end

    def call
      return [] if @user.ow_user_id.blank?

      @client.connections(user_id: @user.ow_user_id)
    end
  end
end
