# frozen_string_literal: true

require "test_helper"

class BaseArrServiceTest < ActiveSupport::TestCase
  # Don't load fixtures for service tests
  class << self
    def fixture_paths
      []
    end
  end

  setup do
    @service = BaseArrService.new("http://localhost:7878", "test_api_key")
  end

  test "remux? returns true for REMUX quality strings" do
    assert(@service.remux?("Remux-1080p"))
    assert(@service.remux?("Remux-2160p"))
    assert(@service.remux?("REMUX-1080p"))
  end

  test "remux? returns false for non-REMUX quality strings" do
    refute(@service.remux?("Bluray-1080p"))
    refute(@service.remux?("WEBDL-1080p"))
    refute(@service.remux?("HDTV-720p"))
  end

  test "remux? returns false for nil" do
    refute(@service.remux?(nil))
  end

  test "test_connection succeeds with valid API" do
    stub_request(:get, "http://localhost:7878/api/v3/system/status")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: '{"version":"1.0"}', headers: {})

    assert(@service.test_connection)
  end

  test "test_connection fails with invalid API key" do
    stub_request(:get, "http://localhost:7878/api/v3/system/status")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 401, body: "", headers: {})

    refute(@service.test_connection)
  end

  test "test_connection fails with network error" do
    stub_request(:get, "http://localhost:7878/api/v3/system/status")
      .to_raise(Faraday::ConnectionFailed.new("Connection refused"))

    refute(@service.test_connection)
  end
end
