# frozen_string_literal: true

class ExportsController < ApplicationController
  def index
    # Display the exports page with export options
  end

  def movies
    # Parse parameters
    remux_only = params[:remux_only] == "true"
    include_ignored = params[:include_ignored] == "true"

    # Build query
    movies_query = Movie.all
    movies_query = movies_query.remux_only if remux_only
    movies_query = movies_query.with_ignored_option(include_ignored)
    movies_query = movies_query.ordered_by_title

    # Prepare data
    movies_data = movies_query.map do |movie|
      {
        id: movie.id,
        title: movie.title,
        year: movie.year,
        tmdb_id: movie.tmdb_id,
        radarr_id: movie.radarr_id,
        file_path: movie.file_path,
        size_bytes: movie.size_bytes,
        quality_profile: movie.quality_profile,
        quality: movie.quality,
        is_remux: movie.is_remux,
        ignored: movie.ignored,
        last_refreshed_at: movie.last_refreshed_at,
        created_at: movie.created_at,
        updated_at: movie.updated_at,
      }
    end

    # Generate filename
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    filter_suffix = remux_only ? "remux" : "all"
    ignored_suffix = include_ignored ? "with_ignored" : "no_ignored"
    filename = "movies_#{filter_suffix}_#{ignored_suffix}_#{timestamp}.json"

    # Send file
    send_data(
      JSON.pretty_generate(movies_data),
      type: "application/json",
      disposition: "attachment; filename=#{filename}",
    )
  end

  def shows
    # Parse parameters
    remux_only = params[:remux_only] == "true"
    include_ignored = params[:include_ignored] == "true"

    # Build query
    shows_query = Show.includes(seasons: :episodes).all
    shows_query = shows_query.with_remux if remux_only
    shows_query = shows_query.with_ignored_option(include_ignored)
    shows_query = shows_query.ordered_by_title

    # Prepare data with nested structure
    shows_data = shows_query.map do |show|
      {
        id: show.id,
        title: show.title,
        year: show.year,
        tvdb_id: show.tvdb_id,
        sonarr_id: show.sonarr_id,
        total_size_bytes: show.total_size_bytes,
        contains_remux: show.contains_remux,
        ignored: show.ignored,
        last_refreshed_at: show.last_refreshed_at,
        created_at: show.created_at,
        updated_at: show.updated_at,
        seasons: show.seasons.map do |season|
          # Filter episodes if remux_only is true
          episodes_to_export = remux_only ? season.episodes.select(&:is_remux) : season.episodes

          {
            id: season.id,
            season_number: season.season_number,
            total_size_bytes: season.total_size_bytes,
            contains_remux: season.contains_remux,
            created_at: season.created_at,
            updated_at: season.updated_at,
            episodes: episodes_to_export.map do |episode|
              {
                id: episode.id,
                episode_number: episode.episode_number,
                title: episode.title,
                file_path: episode.file_path,
                size_bytes: episode.size_bytes,
                quality_profile: episode.quality_profile,
                quality: episode.quality,
                is_remux: episode.is_remux,
                created_at: episode.created_at,
                updated_at: episode.updated_at,
              }
            end,
          }
        end,
      }
    end

    # Generate filename
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    filter_suffix = remux_only ? "remux" : "all"
    ignored_suffix = include_ignored ? "with_ignored" : "no_ignored"
    filename = "shows_#{filter_suffix}_#{ignored_suffix}_#{timestamp}.json"

    # Send file
    send_data(
      JSON.pretty_generate(shows_data),
      type: "application/json",
      disposition: "attachment; filename=#{filename}",
    )
  end
end
