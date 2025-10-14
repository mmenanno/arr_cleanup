# frozen_string_literal: true

class BaseArrService
  attr_reader :url, :api_key

  def initialize(url, api_key)
    @url = url
    @api_key = api_key
  end

  def test_connection
    response = get("/api/v3/system/status")
    response.success?
  rescue StandardError => e
    Rails.logger.error("Connection test failed: #{e.message}")
    false
  end

  def remux?(quality)
    return false if quality.nil?

    quality.to_s.downcase.include?("remux")
  end

  protected

  def get(endpoint)
    connection.get(endpoint)
  end

  def connection
    @connection ||= Faraday.new(url:) do |faraday|
      faraday.headers["X-Api-Key"] = api_key
      faraday.headers["Content-Type"] = "application/json"
      faraday.adapter(Faraday.default_adapter)
    end
  end

  def parse_response(response)
    return unless response.success?

    JSON.parse(response.body, symbolize_names: true)
  end
end
