require "net/http"
require "json"
require "uri"

module OpenWearables
  class Client
    API_KEY_HEADER = "X-Open-Wearables-API-Key".freeze

    def initialize(api_key: ENV["OPEN_WEARABLES_API_KEY"], api_url: ENV["OPEN_WEARABLES_API_URL"])
      @api_key = api_key
      @api_url = api_url
    end

    def create_user(attributes = {})
      post("/api/v1/users", attributes)
    end

    def list_providers(cloud_only: true, enabled_only: true)
      get("/api/v1/oauth/providers", cloud_only: cloud_only, enabled_only: enabled_only)
    end

    def authorize_url(provider:, user_id:, redirect_uri:)
      get("/api/v1/oauth/#{provider}/authorize", user_id: user_id, redirect_uri: redirect_uri)
    end

    def connections(user_id:)
      get("/api/v1/users/#{user_id}/connections")
    end

    private

    def get(path, params = {})
      uri = build_uri(path)
      uri.query = URI.encode_www_form(params) if params.any?
      perform(Net::HTTP::Get.new(uri))
    end

    def post(path, payload = nil)
      uri = build_uri(path)
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body = payload.to_json if payload
      perform(req)
    end

    def build_uri(path)
      URI.join(@api_url, path)
    end

    def perform(req)
      req[API_KEY_HEADER] = @api_key
      req["Accept"] = "application/json"
      uri = req.uri
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req)
      end
      handle_response(response)
    end

    def handle_response(response)
      body = parse_body(response)
      return body if response.code.to_i.between?(200, 299)

      raise Error.new(
        "Open Wearables API error (#{response.code})",
        status: response.code.to_i,
        body: body
      )
    end

    def parse_body(response)
      return nil if response.body.nil? || response.body.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
  end
end
