# frozen_string_literal: true

require "test_helper"

class ShowsControllerTest < ActionDispatch::IntegrationTest
  fixtures :shows, :seasons, :episodes

  test "should get index" do
    get shows_url

    assert_response :success
  end

  test "should get show" do
    get show_url(shows(:test_show))

    assert_response :success
  end
end
