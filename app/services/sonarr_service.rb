# frozen_string_literal: true

class SonarrService < BaseArrService
  def fetch_all_shows
    response = get("/api/v3/series")
    series_data = parse_response(response)
    return [] unless series_data

    series_data.map { |series| parse_show_with_episodes(series) }
  end

  def fetch_show(sonarr_id)
    response = get("/api/v3/series/#{sonarr_id}")
    series_data = parse_response(response)
    return unless series_data

    parse_show_with_episodes(series_data)
  end

  private

  def parse_show_with_episodes(series_data)
    series_id = series_data[:id]

    # Fetch episodes and episode files separately
    episodes_data = fetch_episodes(series_id)
    files_data = fetch_episode_files(series_id)

    # Create a hash of file data by episodeFileId for quick lookup
    files_by_id = files_data.index_by { |file| file[:id] }

    {
      sonarr_id: series_id,
      title: series_data[:title],
      year: series_data[:year],
      tvdb_id: series_data[:tvdbId],
      seasons: group_episodes_by_season(episodes_data, files_by_id),
    }
  end

  def fetch_episodes(series_id)
    response = get("/api/v3/episode?seriesId=#{series_id}")
    episodes_data = parse_response(response)
    return [] unless episodes_data

    episodes_data
  end

  def fetch_episode_files(series_id)
    response = get("/api/v3/episodefile?seriesId=#{series_id}")
    files_data = parse_response(response)
    return [] unless files_data

    files_data
  end

  def group_episodes_by_season(episodes_data, files_by_id)
    # Only include episodes that have a file
    episodes_with_files = episodes_data.filter do |ep|
      ep[:hasFile] && ep[:episodeFileId] && files_by_id[ep[:episodeFileId]]
    end

    grouped = episodes_with_files.group_by { |ep| ep[:seasonNumber] }

    grouped.map do |season_number, episodes|
      {
        season_number:,
        episodes: episodes.map { |ep| parse_episode(ep, files_by_id[ep[:episodeFileId]]) },
      }
    end
  end

  def parse_episode(episode_data, episode_file)
    quality = episode_file.dig(:quality, :quality, :name)

    {
      episode_number: episode_data[:episodeNumber],
      title: episode_data[:title],
      file_path: episode_file[:path],
      size_bytes: episode_file[:size],
      quality_profile: nil, # Sonarr v3 API doesn't include quality profile name in episode file
      quality:,
      is_remux: remux?(quality),
    }
  end
end
