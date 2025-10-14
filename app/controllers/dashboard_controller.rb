# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @include_ignored = params[:include_ignored] == "true"
    @app_setting = AppSetting.instance

    # Sync status
    @radarr_status = SyncStatus.for_service(:radarr)
    @sonarr_status = SyncStatus.for_service(:sonarr)

    # Calculate statistics
    movies_scope = @include_ignored ? Movie.all : Movie.not_ignored
    shows_scope = @include_ignored ? Show.all : Show.not_ignored

    @total_movies = movies_scope.count
    @ignored_movies = Movie.where(ignored: true).count
    @remux_movies = movies_scope.where(is_remux: true).count
    @total_movie_size = movies_scope.sum(:size_bytes)

    @total_shows = shows_scope.count
    @ignored_shows = Show.where(ignored: true).count
    @remux_shows = shows_scope.where(contains_remux: true).count
    @total_show_size = shows_scope.sum(:total_size_bytes)

    @total_storage = @total_movie_size + @total_show_size

    # Top largest items
    @largest_movies = movies_scope.ordered_by_size_desc.limit(5)
    @largest_shows = shows_scope.ordered_by_size_desc.limit(5)
  end
end
