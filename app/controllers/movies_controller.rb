# frozen_string_literal: true

class MoviesController < ApplicationController
  include Pagy::Backend

  before_action :set_movie, only: [:show, :refresh, :ignore, :unignore]

  def index
    @show_ignored = params[:show_ignored] == "true"
    @remux_only = params[:remux_only] == "true"
    @sort = params[:sort] || "size"
    @direction = params[:direction] || "desc"
    @query = params[:q]

    movies = Movie.all
    movies = movies.with_ignored_option(@show_ignored)
    movies = movies.remux_only if @remux_only
    movies = movies.search_by_title(@query) if @query.present?

    movies = case @sort
    when "title"
      movies.order(title: @direction)
    when "year"
      movies.order(year: @direction)
    when "ignored"
      movies.order(ignored: @direction, size_bytes: :desc)
    else # size
      movies.order(size_bytes: @direction)
    end

    @pagy, @movies = pagy(movies, limit: 25)
  end

  def show
  end

  def sync_all
    app_setting = AppSetting.instance

    # Check if Radarr is configured
    if app_setting.radarr_url.blank? || app_setting.radarr_api_key.blank?
      respond_to do |format|
        format.turbo_stream { render(turbo_stream: show_toast("Please configure Radarr in Settings before syncing", type: "error")) }
        format.html { redirect_to(movies_path, alert: "Please configure Radarr in Settings before syncing") }
      end
      return
    end

    # Set status to queued
    sync_status = SyncStatus.for_service(:radarr)
    sync_status.update!(
      status: "queued",
      message: "Waiting to start...",
      progress_current: 0,
      progress_total: 0,
    )
    sync_status.broadcast_update

    SyncRadarrJob.perform_later

    respond_to do |format|
      format.turbo_stream { render(turbo_stream: show_toast("Radarr sync queued", type: "success")) }
      format.html { redirect_to(movies_path, notice: "Radarr sync queued") }
    end
  end

  def refresh
    app_setting = AppSetting.instance
    return if app_setting.radarr_url.blank? || app_setting.radarr_api_key.blank?

    service = RadarrService.new(app_setting.radarr_url, app_setting.radarr_api_key)
    movie_data = service.fetch_movie(@movie.radarr_id)

    if movie_data
      @movie.update!(
        title: movie_data[:title],
        year: movie_data[:year],
        tmdb_id: movie_data[:tmdb_id],
        file_path: movie_data[:file_path],
        size_bytes: movie_data[:size_bytes],
        quality_profile: movie_data[:quality_profile],
        quality: movie_data[:quality],
        is_remux: movie_data[:is_remux],
        last_refreshed_at: Time.current,
      )

      respond_to do |format|
        format.turbo_stream do
          streams = []

          streams << if request.referer&.include?("/movies/#{@movie.id}")
            # On show page - replace the details section
            turbo_stream.replace("movie_details_#{@movie.id}", partial: "movies/show_details", locals: { movie: @movie })
          else
            # On index page - replace the row
            turbo_stream.replace(@movie, partial: "movies/movie", locals: { movie: @movie })
          end
          streams << show_toast("Movie refreshed successfully", type: "success")
          render(turbo_stream: streams)
        end
        format.html { redirect_to(@movie, notice: "Movie refreshed successfully") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render(turbo_stream: show_toast("Failed to refresh movie", type: "error")) }
        format.html { redirect_to(@movie, alert: "Failed to refresh movie") }
      end
    end
  end

  def ignore
    @movie.update!(ignored: true)

    respond_to do |format|
      format.turbo_stream do
        streams = []
        # If on index page, replace the row
        streams << if request.referer&.include?("/movies") && !request.referer&.include?("/movies/#{@movie.id}")
          turbo_stream.replace(@movie, partial: "movies/movie", locals: { movie: @movie })
        else
          # On show page, replace the actions
          turbo_stream.replace("movie_actions_#{@movie.id}", partial: "movies/actions", locals: { movie: @movie })
        end
        streams << show_toast("Movie ignored - use filter to hide", type: "success")
        render(turbo_stream: streams)
      end
      format.html { redirect_to(movies_path, notice: "Movie ignored") }
    end
  end

  def unignore
    @movie.update!(ignored: false)

    respond_to do |format|
      format.turbo_stream do
        streams = []
        # If on index page, replace the row
        streams << if request.referer&.include?("/movies") && !request.referer&.include?("/movies/#{@movie.id}")
          turbo_stream.replace(@movie, partial: "movies/movie", locals: { movie: @movie })
        else
          # On show page, replace the actions
          turbo_stream.replace("movie_actions_#{@movie.id}", partial: "movies/actions", locals: { movie: @movie })
        end
        streams << show_toast("Movie unignored", type: "success")
        render(turbo_stream: streams)
      end
      format.html { redirect_to(movies_path, notice: "Movie unignored") }
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end
end
