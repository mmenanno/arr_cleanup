# frozen_string_literal: true

require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get edit_settings_url

    assert_response :success
  end

  test "should update settings" do
    # Get the singleton instance
    setting = AppSetting.instance

    patch settings_url, params: {
      app_setting: {
        radarr_url: "http://localhost:7878",
      },
    }

    assert_redirected_to edit_settings_path

    # Verify URL was updated (non-encrypted field)
    setting.reload

    assert_equal "http://localhost:7878", setting.radarr_url
  end
end
