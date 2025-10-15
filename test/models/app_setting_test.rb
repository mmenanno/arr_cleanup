# frozen_string_literal: true

require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  test "encrypts and decrypts API keys" do
    setting = AppSetting.instance

    setting.radarr_api_key = "secret_radarr_key"
    setting.sonarr_api_key = "secret_sonarr_key"

    assert(setting.save)

    setting.reload

    assert_equal("secret_radarr_key", setting.radarr_api_key)
    assert_equal("secret_sonarr_key", setting.sonarr_api_key)
  end
end
