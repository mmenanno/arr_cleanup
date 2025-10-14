# frozen_string_literal: true

require "test_helper"

class SonarrServiceTest < ActiveSupport::TestCase
  # Don't load fixtures for service tests
  class << self
    def fixture_paths
      []
    end
  end

  setup do
    @service = SonarrService.new("http://localhost:8989", "test_api_key")
    @series_response = JSON.parse(file_fixture("sonarr_series_response.json").read)
    @episodes_response = JSON.parse(file_fixture("sonarr_episodes_response.json").read)
    @episode_files_response = [
      {
        id: 1,
        seriesId: 1,
        seasonNumber: 1,
        path: "/path/to/episode1.mkv",
        size: 3_000_000_000,
        quality: {
          quality: {
            id: 10,
            name: "Remux-1080p",
          },
        },
      },
      {
        id: 2,
        seriesId: 1,
        seasonNumber: 1,
        path: "/path/to/episode2.mkv",
        size: 2_500_000_000,
        quality: {
          quality: {
            id: 4,
            name: "HDTV-1080p",
          },
        },
      },
    ].freeze
  end

  test "fetch_all_shows returns parsed show data with episodes" do
    stub_request(:get, "http://localhost:8989/api/v3/series")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @series_response.to_json, headers: { "Content-Type" => "application/json" })

    stub_request(:get, "http://localhost:8989/api/v3/episode?seriesId=1")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @episodes_response.to_json, headers: { "Content-Type" => "application/json" })

    stub_request(:get, "http://localhost:8989/api/v3/episodefile?seriesId=1")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @episode_files_response.to_json, headers: { "Content-Type" => "application/json" })

    shows = @service.fetch_all_shows

    assert_equal(1, shows.size)

    show = shows.first

    assert_equal("Test Show", show[:title])
    assert_equal(2020, show[:year])
    assert_equal(123_456, show[:tvdb_id])
    assert_equal(1, show[:sonarr_id])

    assert_equal(1, show[:seasons].size)
    season = show[:seasons].first

    assert_equal(1, season[:season_number])
    assert_equal(2, season[:episodes].size)

    first_episode = season[:episodes].first

    assert_equal(1, first_episode[:episode_number])
    assert_equal("Pilot", first_episode[:title])
    assert_equal(3_000_000_000, first_episode[:size_bytes])
    assert_equal("Remux-1080p", first_episode[:quality])
    assert(first_episode[:is_remux])
  end

  test "fetch_show returns single show data with episodes" do
    stub_request(:get, "http://localhost:8989/api/v3/series/1")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @series_response.first.to_json, headers: { "Content-Type" => "application/json" })

    stub_request(:get, "http://localhost:8989/api/v3/episode?seriesId=1")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @episodes_response.to_json, headers: { "Content-Type" => "application/json" })

    stub_request(:get, "http://localhost:8989/api/v3/episodefile?seriesId=1")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @episode_files_response.to_json, headers: { "Content-Type" => "application/json" })

    show = @service.fetch_show(1)

    assert_equal("Test Show", show[:title])
    assert_equal(1, show[:sonarr_id])
    assert_equal(1, show[:seasons].size)
  end
end
