# frozen_string_literal: true

class AppSetting < ApplicationRecord
  encrypts :radarr_api_key, :sonarr_api_key

  validates :radarr_url, format: { with: URI::DEFAULT_PARSER.make_regexp(["http", "https"]), allow_blank: true }
  validates :sonarr_url, format: { with: URI::DEFAULT_PARSER.make_regexp(["http", "https"]), allow_blank: true }

  class << self
    def instance
      first_or_create!
    end
  end
end
