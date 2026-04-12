require "net/http"
require "json"

class OpenWearablesClient
  API_VERSION = "api/v1"

  class ApiError < StandardError
    attr_reader :status, :body

    def initialize(message, status: nil, body: nil)
      @status = status
      @body = body
      super(message)
    end
  end

  def initialize(api_key: credentials.api_key, base_url: credentials.api_url)
    @api_key = api_key
    @base_url = base_url
  end

  # POST /api/v1/users
  def create_user(external_user_id:)
    post("/#{API_VERSION}/users", { external_user_id: external_user_id })
  end

  # GET /api/v1/oauth/providers
  def get_providers(enabled_only: true, cloud_only: true)
    get("/#{API_VERSION}/oauth/providers", enabled_only: enabled_only, cloud_only: cloud_only)
  end

  # GET /api/v1/oauth/{provider}/authorize
  def authorize_provider(provider:, user_id:, redirect_uri:)
    get("/#{API_VERSION}/oauth/#{provider}/authorize", user_id: user_id, redirect_uri: redirect_uri)
  end

  # GET /api/v1/users/{user_id}/connections
  def get_connections(user_id:)
    get("/#{API_VERSION}/users/#{user_id}/connections")
  end

  private

  def credentials
    Rails.application.credentials.open_wearables
  end

  def get(path, params = {})
    uri = build_uri(path, params)
    request = Net::HTTP::Get.new(uri)
    execute(uri, request)
  end

  def post(path, body = {})
    uri = build_uri(path)
    request = Net::HTTP::Post.new(uri)
    request.body = body.to_json
    request["Content-Type"] = "application/json"
    execute(uri, request)
  end

  def build_uri(path, params = {})
    uri = URI("#{@base_url}#{path}")
    uri.query = URI.encode_www_form(params) if params.any?
    uri
  end

  def execute(uri, request)
    request["X-Open-Wearables-API-Key"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.open_timeout = 10
      http.read_timeout = 15
      http.request(request)
    end

    parsed = JSON.parse(response.body)

    unless response.is_a?(Net::HTTPSuccess)
      raise ApiError.new(
        "API returned #{response.code}: #{parsed}",
        status: response.code.to_i,
        body: parsed
      )
    end

    parsed
  end
end
