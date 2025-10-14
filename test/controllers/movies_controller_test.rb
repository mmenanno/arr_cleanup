# frozen_string_literal: true

require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  fixtures :movies

  test "should get index" do
    get movies_url

    assert_response :success
  end

  test "should get show" do
    get movie_url(movies(:another_round))

    assert_response :success
  end
end
