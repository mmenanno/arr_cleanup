# frozen_string_literal: true

class SyncSonarrJob < BaseSyncJob
  protected

  def service_type
    :sonarr
  end

  def sync_data
    if app_settings.sonarr_url.blank? || app_settings.sonarr_api_key.blank?
      update_progress(0, 0, message: "Sonarr not configured. Please add URL and API key in Settings.")
      return
    end

    service = SonarrService.new(app_settings.sonarr_url, app_settings.sonarr_api_key)
    shows_data = service.fetch_all_shows

    total = shows_data.size
    if total.zero?
      update_progress(0, 0, message: "No shows found in Sonarr. Check your Sonarr library.")
      return
    end

    shows_data.each_with_index do |show_data, index|
      sync_show(show_data)

      # Update progress
      update_progress(index + 1, total, message: "Syncing shows: #{index + 1}/#{total}")
    end

    Rails.logger.info("Synced #{total} shows from Sonarr")
  end

  private

  def sync_show(show_data)
    show = Show.find_or_initialize_by(sonarr_id: show_data[:sonarr_id])

    # Preserve ignored status if show already exists
    ignored_status = show.persisted? ? show.ignored : false

    show.assign_attributes(
      title: show_data[:title],
      year: show_data[:year],
      tvdb_id: show_data[:tvdb_id],
      ignored: ignored_status,
      last_refreshed_at: Time.current,
    )

    show.save!

    # Sync seasons and episodes
    show_data[:seasons].each do |season_data|
      sync_season(show, season_data)
    end

    # Update show totals
    show.update!(
      total_size_bytes: show.seasons.sum(:total_size_bytes),
      contains_remux: show.seasons.exists?(contains_remux: true),
    )
  end

  def sync_season(show, season_data)
    season = show.seasons.find_or_initialize_by(season_number: season_data[:season_number])
    season.save!

    # Sync episodes
    season_data[:episodes].each do |episode_data|
      sync_episode(season, episode_data)
    end

    # Update season totals
    season.reload.update_totals!
  end

  def sync_episode(season, episode_data)
    episode = season.episodes.find_or_initialize_by(episode_number: episode_data[:episode_number])

    episode.assign_attributes(
      title: episode_data[:title],
      file_path: episode_data[:file_path],
      size_bytes: episode_data[:size_bytes],
      quality_profile: episode_data[:quality_profile],
      quality: episode_data[:quality],
      is_remux: episode_data[:is_remux],
    )

    episode.save!
  end
end
