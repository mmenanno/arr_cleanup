# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  fixtures :app_settings, :movies, :shows, :seasons, :episodes

  test "should get index" do
    get root_url

    assert_response :success
  end
end
