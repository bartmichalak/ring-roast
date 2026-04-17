require "test_helper"

module OpenWearables
  class ListProvidersTest < ActiveSupport::TestCase
    setup do
      ENV["OPEN_WEARABLES_API_URL"] = "https://api.example.com"
    end

    test "prepends API base URL to relative icon_url" do
      client = fake_client([
        { "provider" => "garmin", "name" => "Garmin", "icon_url" => "/static/icons/garmin.svg" }
      ])
      result = ListProviders.new(client: client).call

      assert_equal "https://api.example.com/static/icons/garmin.svg", result.first["icon_url"]
    end

    test "leaves absolute icon urls untouched" do
      client = fake_client([
        { "provider" => "oura", "name" => "Oura", "icon_url" => "https://cdn/oura.svg" }
      ])
      result = ListProviders.new(client: client).call

      assert_equal "https://cdn/oura.svg", result.first["icon_url"]
    end

    test "requests cloud_only and enabled_only from the client" do
      captured = {}
      client = Object.new
      client.define_singleton_method(:list_providers) do |**opts|
        captured[:opts] = opts
        []
      end

      ListProviders.new(client: client).call

      assert_equal({ cloud_only: true, enabled_only: true }, captured[:opts])
    end

    private

    def fake_client(providers)
      client = Object.new
      client.define_singleton_method(:list_providers) { |**_opts| providers }
      client
    end
  end
end
