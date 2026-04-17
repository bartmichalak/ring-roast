require "net/http"
require "json"

module OpenWearables
  class Client
    def initialize(api_key: ENV["OPEN_WEARABLES_API_KEY"], api_url: ENV["OPEN_WEARABLES_API_URL"])
      raise Error, "OPEN_WEARABLES_API_KEY is not configured" if api_key.blank?
      raise Error, "OPEN_WEARABLES_API_URL is not configured" if api_url.blank?

      @api_key = api_key
      @api_url = api_url.chomp("/")
    end

    def api_base_url
      @api_url
    end

    def create_user(attributes = {})
      post("/api/v1/users", attributes)
    end

    def list_providers
      get("/api/v1/oauth/providers")
    end

    def get_authorize_url(provider:, user_id:, redirect_uri: nil)
      params = { user_id: user_id }
      params[:redirect_uri] = redirect_uri if redirect_uri.present?
      get("/api/v1/oauth/#{provider}/authorize", params)
    end

    def get_connections(user_id:)
      get("/api/v1/users/#{user_id}/connections")
    end

    def get_workouts(user_id:, start_date: nil, end_date: nil, cursor: nil, limit: nil)
      params = {}
      params[:start_date] = start_date.to_s if start_date
      params[:end_date] = end_date.to_s if end_date
      params[:cursor] = cursor if cursor
      params[:limit] = limit if limit
      get("/api/v1/users/#{user_id}/events/workouts", params)
    end

    private

    def get(path, params = {})
      uri = URI("#{@api_url}#{path}")
      uri.query = URI.encode_www_form(params) if params.any?
      perform(Net::HTTP::Get.new(uri), uri)
    end

    def post(path, body)
      uri = URI("#{@api_url}#{path}")
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body = body.to_json
      perform(req, uri)
    end

    def perform(req, uri)
      req["X-Open-Wearables-API-Key"] = @api_key
      req["Accept"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(req)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise Error.new(
          "Open Wearables API error: #{response.code} #{response.message}",
          status: response.code.to_i,
          body: response.body
        )
      end

      return nil if response.body.blank?
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise Error, "Invalid JSON response from Open Wearables: #{e.message}"
    end
  end
end
