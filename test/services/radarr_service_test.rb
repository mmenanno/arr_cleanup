# frozen_string_literal: true

require "test_helper"

class RadarrServiceTest < ActiveSupport::TestCase
  # Don't load fixtures for service tests
  class << self
    def fixture_paths
      []
    end
  end

  setup do
    @service = RadarrService.new("http://localhost:7878", "test_api_key")
    @movies_response = JSON.parse(file_fixture("radarr_movies_response.json").read)
  end

  test "fetch_all_movies returns parsed movie data" do
    stub_request(:get, "http://localhost:7878/api/v3/movie")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @movies_response.to_json, headers: { "Content-Type" => "application/json" })

    movies = @service.fetch_all_movies

    assert_equal(2, movies.size)
    assert_equal("Another Round", movies.first[:title])
    assert_equal(2020, movies.first[:year])
    assert_equal(580175, movies.first[:tmdb_id])
    assert_equal(1, movies.first[:radarr_id])
    assert_equal(20_000_000_000, movies.first[:size_bytes])
    assert_equal("Remux-1080p", movies.first[:quality])
    assert_equal("HD-1080p", movies.first[:quality_profile])
    assert(movies.first[:is_remux])
  end

  test "fetch_all_movies handles movies without files" do
    movies_data = @movies_response.dup
    movies_data << {
      "id" => 3,
      "title" => "No File Movie",
      "year" => 2022,
      "tmdbId" => 789,
      "hasFile" => false,
    }

    stub_request(:get, "http://localhost:7878/api/v3/movie")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: movies_data.to_json, headers: { "Content-Type" => "application/json" })

    movies = @service.fetch_all_movies

    assert_equal(2, movies.size) # Should skip movie without file
  end

  test "fetch_movie returns single movie data" do
    stub_request(:get, "http://localhost:7878/api/v3/movie/1")
      .with(headers: { "X-Api-Key" => "test_api_key" })
      .to_return(status: 200, body: @movies_response.first.to_json, headers: { "Content-Type" => "application/json" })

    movie = @service.fetch_movie(1)

    assert_equal("Another Round", movie[:title])
    assert_equal(1, movie[:radarr_id])
  end
end
