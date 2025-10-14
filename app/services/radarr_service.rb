# frozen_string_literal: true

class RadarrService < BaseArrService
  def fetch_all_movies
    response = get("/api/v3/movie")
    movies_data = parse_response(response)
    return [] unless movies_data

    movies_data.filter_map { |movie| parse_movie(movie) }
  end

  def fetch_movie(radarr_id)
    response = get("/api/v3/movie/#{radarr_id}")
    movie_data = parse_response(response)
    return unless movie_data

    parse_movie(movie_data)
  end

  private

  def parse_movie(movie_data)
    return unless movie_data[:hasFile] && movie_data[:movieFile]

    movie_file = movie_data[:movieFile]
    quality = movie_file.dig(:quality, :quality, :name)

    {
      radarr_id: movie_data[:id],
      title: movie_data[:title],
      year: movie_data[:year],
      tmdb_id: movie_data[:tmdbId],
      file_path: movie_file[:path],
      size_bytes: movie_file[:size],
      quality_profile: movie_file.dig(:qualityProfile, :name) || movie_data.dig(:qualityProfileId),
      quality:,
      is_remux: remux?(quality),
    }
  end
end
