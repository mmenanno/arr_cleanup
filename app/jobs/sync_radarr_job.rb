# frozen_string_literal: true

class SyncRadarrJob < BaseSyncJob
  protected

  def service_type
    :radarr
  end

  def sync_data
    if app_settings.radarr_url.blank? || app_settings.radarr_api_key.blank?
      update_progress(0, 0, message: "Radarr not configured. Please add URL and API key in Settings.")
      return
    end

    service = RadarrService.new(app_settings.radarr_url, app_settings.radarr_api_key)
    movies_data = service.fetch_all_movies

    total = movies_data.size
    if total.zero?
      update_progress(0, 0, message: "No movies found in Radarr. Check your Radarr library.")
      return
    end

    movies_data.each_with_index do |movie_data, index|
      movie = Movie.find_or_initialize_by(radarr_id: movie_data[:radarr_id])

      # Preserve ignored status if movie already exists
      ignored_status = movie.persisted? ? movie.ignored : false

      movie.assign_attributes(
        title: movie_data[:title],
        year: movie_data[:year],
        tmdb_id: movie_data[:tmdb_id],
        file_path: movie_data[:file_path],
        size_bytes: movie_data[:size_bytes],
        quality_profile: movie_data[:quality_profile],
        quality: movie_data[:quality],
        is_remux: movie_data[:is_remux],
        ignored: ignored_status,
        last_refreshed_at: Time.current,
      )

      movie.save!

      # Update progress
      update_progress(index + 1, total, message: "Syncing movies: #{index + 1}/#{total}")
    end

    Rails.logger.info("Synced #{total} movies from Radarr")
  end
end
