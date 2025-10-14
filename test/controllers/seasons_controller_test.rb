# frozen_string_literal: true

require "test_helper"

class SeasonsControllerTest < ActionDispatch::IntegrationTest
  fixtures :shows, :seasons, :episodes

  test "should get show" do
    get show_season_url(shows(:test_show), seasons(:season_one))

    assert_response :success
  end
end
