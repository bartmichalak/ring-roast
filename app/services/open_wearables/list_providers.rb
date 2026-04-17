module OpenWearables
  class ListProviders
    def initialize(client: Client.new)
      @client = client
    end

    def call
      providers = @client.list_providers(cloud_only: true, enabled_only: true)
      providers.map { |p| decorate(p) }
    end

    private

    def decorate(provider)
      provider.merge(
        "icon_url" => absolute_icon_url(provider["icon_url"])
      )
    end

    def absolute_icon_url(path)
      return nil if path.blank?
      return path if path.start_with?("http")

      URI.join(ENV["OPEN_WEARABLES_API_URL"], path).to_s
    end
  end
end
