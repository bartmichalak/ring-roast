module OpenWearables
  class StartConnection
    def initialize(user:, provider:, redirect_uri:, client: Client.new)
      @user = user
      @provider = provider
      @redirect_uri = redirect_uri
      @client = client
    end

    def call
      ensure_ow_user!
      response = @client.authorize_url(
        provider: @provider,
        user_id: @user.ow_user_id,
        redirect_uri: @redirect_uri
      )
      response.fetch("authorization_url")
    end

    private

    def ensure_ow_user!
      return if @user.ow_user_id.present?

      response = @client.create_user
      @user.update!(ow_user_id: response.fetch("id"))
    end
  end
end
