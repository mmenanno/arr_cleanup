# frozen_string_literal: true

require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  fixtures :movies, :shows, :seasons, :episodes

  test "should get index" do
    get exports_url

    assert_response :success
  end

  # Movies Export Tests

  test "should export all movies excluding ignored" do
    get movies_exports_url(remux_only: false, include_ignored: false), as: :json

    assert_response :success
    assert_equal "application/json", response.content_type

    data = response.parsed_body

    assert_equal 2, data.length # another_round and test_movie

    titles = data.pluck("title").sort

    assert_equal ["Another Round", "Test Movie"], titles
  end

  test "exported movies should include all required fields" do
    get movies_exports_url(remux_only: false, include_ignored: false), as: :json

    data = response.parsed_body
    first_movie = data.first
    expected_fields = [
      "id",
      "title",
      "year",
      "tmdb_id",
      "radarr_id",
      "file_path",
      "size_bytes",
      "quality_profile",
      "quality",
      "is_remux",
      "ignored",
      "created_at",
      "updated_at",
    ]

    expected_fields.each do |field|
      assert_includes first_movie.keys, field
    end
  end

  test "should export all movies including ignored" do
    get movies_exports_url(remux_only: false, include_ignored: true), as: :json

    assert_response :success

    data = response.parsed_body

    assert_equal 3, data.length # another_round, test_movie, and ignored_movie

    titles = data.pluck("title").sort

    assert_equal ["Another Round", "Ignored Movie", "Test Movie"], titles
  end

  test "should export remux movies only excluding ignored" do
    get movies_exports_url(remux_only: true, include_ignored: false), as: :json

    assert_response :success

    data = response.parsed_body

    assert_equal 1, data.length # only another_round

    assert_equal "Another Round", data.first["title"]
    assert data.first["is_remux"]
  end

  test "should export remux movies only including ignored" do
    get movies_exports_url(remux_only: true, include_ignored: true), as: :json

    assert_response :success

    data = response.parsed_body

    assert_equal 2, data.length # another_round and ignored_movie

    titles = data.pluck("title").sort

    assert_equal ["Another Round", "Ignored Movie"], titles

    # Verify all are remux
    data.each do |movie|
      assert movie["is_remux"], "Expected all movies to be remux"
    end
  end

  test "movies export should have correct filename format" do
    get movies_exports_url(remux_only: false, include_ignored: false), as: :json

    assert_response :success
    assert_match(/movies_all_no_ignored_\d{8}_\d{6}\.json/, response.headers["Content-Disposition"])
  end

  test "remux movies export should have correct filename format" do
    get movies_exports_url(remux_only: true, include_ignored: true), as: :json

    assert_response :success
    assert_match(/movies_remux_with_ignored_\d{8}_\d{6}\.json/, response.headers["Content-Disposition"])
  end

  # Shows Export Tests

  test "should export all shows excluding ignored" do
    get shows_exports_url(remux_only: false, include_ignored: false), as: :json

    assert_response :success
    assert_equal "application/json", response.content_type

    data = response.parsed_body

    assert_equal 1, data.length # only test_show

    show = data.first

    assert_equal "Test Show", show["title"]
  end

  test "exported shows should include all required fields" do
    get shows_exports_url(remux_only: false, include_ignored: false), as: :json

    data = response.parsed_body
    show = data.first
    expected_show_fields = [
      "id",
      "title",
      "year",
      "tvdb_id",
      "sonarr_id",
      "total_size_bytes",
      "contains_remux",
      "ignored",
      "seasons",
    ]

    expected_show_fields.each do |field|
      assert_includes show.keys, field
    end
  end

  test "exported shows should have nested seasons and episodes structure" do
    get shows_exports_url(remux_only: false, include_ignored: false), as: :json

    data = response.parsed_body
    show = data.first

    assert_equal 1, show["seasons"].length

    season = show["seasons"].first
    expected_season_fields = ["id", "season_number", "episodes"]

    expected_season_fields.each do |field|
      assert_includes season.keys, field
    end

    assert_equal 2, season["episodes"].length

    episode = season["episodes"].first
    expected_episode_fields = [
      "id",
      "episode_number",
      "title",
      "file_path",
      "size_bytes",
      "quality",
      "is_remux",
    ]

    expected_episode_fields.each do |field|
      assert_includes episode.keys, field
    end
  end

  test "should export all shows including ignored" do
    get shows_exports_url(remux_only: false, include_ignored: true), as: :json

    assert_response :success

    data = response.parsed_body

    assert_equal 2, data.length # test_show and ignored_show

    titles = data.pluck("title").sort

    assert_equal ["Ignored Show", "Test Show"], titles
  end

  test "should export remux shows only with remux episodes only" do
    get shows_exports_url(remux_only: true, include_ignored: false), as: :json

    assert_response :success

    data = response.parsed_body

    assert_equal 1, data.length # only test_show (has remux episodes)

    show = data.first

    assert_equal "Test Show", show["title"]
    assert show["contains_remux"]

    # Verify only remux episodes are included
    season = show["seasons"].first

    assert_equal 1, season["episodes"].length # only episode_one (remux)

    episode = season["episodes"].first

    assert_equal "Pilot", episode["title"]
    assert episode["is_remux"]
  end

  test "shows export should have correct filename format" do
    get shows_exports_url(remux_only: false, include_ignored: false), as: :json

    assert_response :success
    assert_match(/shows_all_no_ignored_\d{8}_\d{6}\.json/, response.headers["Content-Disposition"])
  end

  test "remux shows export should have correct filename format" do
    get shows_exports_url(remux_only: true, include_ignored: true), as: :json

    assert_response :success
    assert_match(/shows_remux_with_ignored_\d{8}_\d{6}\.json/, response.headers["Content-Disposition"])
  end
end
