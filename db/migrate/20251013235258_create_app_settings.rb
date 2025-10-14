# frozen_string_literal: true

class CreateAppSettings < ActiveRecord::Migration[8.0]
  def change
    create_table(:app_settings) do |t|
      t.string(:radarr_url)
      t.text(:radarr_api_key)
      t.string(:sonarr_url)
      t.text(:sonarr_api_key)
      t.datetime(:radarr_last_synced_at)
      t.datetime(:sonarr_last_synced_at)

      t.timestamps
    end
  end
end
