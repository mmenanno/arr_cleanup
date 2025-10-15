# frozen_string_literal: true

class ShowsController < ApplicationController
  include Pagy::Backend

  before_action :set_show, only: [:show, :refresh, :ignore, :unignore]

  def index
    @show_ignored = params[:show_ignored] == "true"
    @remux_only = params[:remux_only] == "true"
    @sort = params[:sort] || "size"
    @direction = params[:direction] || "desc"
    @query = params[:q]

    shows = Show.all
    shows = shows.with_ignored_option(@show_ignored)
    shows = shows.with_remux if @remux_only
    shows = shows.search_by_title(@query) if @query.present?

    shows = case @sort
    when "title"
      shows.order(title: @direction)
    when "year"
      shows.order(year: @direction)
    when "ignored"
      shows.order(ignored: @direction, total_size_bytes: :desc)
    else # size
      shows.order(total_size_bytes: @direction)
    end

    @pagy, @shows = pagy(shows, limit: 25)
  end

  def show
    @seasons = @show.seasons.includes(:episodes).order(season_number: :asc)
  end

  def sync_all
    app_setting = AppSetting.instance

    # Check if Sonarr is configured
    if app_setting.sonarr_url.blank? || app_setting.sonarr_api_key.blank?
      respond_to do |format|
        format.turbo_stream { render(turbo_stream: show_toast("Please configure Sonarr in Settings before syncing", type: "error")) }
        format.html { redirect_to(shows_path, alert: "Please configure Sonarr in Settings before syncing") }
      end
      return
    end

    # Set status to queued
    sync_status = SyncStatus.for_service(:sonarr)
    sync_status.update!(
      status: "queued",
      message: "Waiting to start...",
      progress_current: 0,
      progress_total: 0,
    )
    sync_status.broadcast_update

    SyncSonarrJob.perform_later

    respond_to do |format|
      format.turbo_stream { render(turbo_stream: show_toast("Sonarr sync queued", type: "success")) }
      format.html { redirect_to(shows_path, notice: "Sonarr sync queued") }
    end
  end

  def refresh
    app_setting = AppSetting.instance
    return if app_setting.sonarr_url.blank? || app_setting.sonarr_api_key.blank?

    service = SonarrService.new(app_setting.sonarr_url, app_setting.sonarr_api_key)
    show_data = service.fetch_show(@show.sonarr_id)

    if show_data
      # Update show
      @show.update!(
        title: show_data[:title],
        year: show_data[:year],
        tvdb_id: show_data[:tvdb_id],
        last_refreshed_at: Time.current,
      )

      # Update seasons and episodes
      show_data[:seasons].each do |season_data|
        season = @show.seasons.find_or_initialize_by(season_number: season_data[:season_number])
        season.save!

        season_data[:episodes].each do |episode_data|
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

        season.reload.update_totals!
      end

      # Update show totals
      @show.update!(
        total_size_bytes: @show.seasons.sum(:total_size_bytes),
        contains_remux: @show.seasons.exists?(contains_remux: true),
      )

      respond_to do |format|
        format.turbo_stream do
          streams = []

          if request.referer&.include?("/shows/#{@show.id}")
            # On show page - reload seasons and replace the details section
            @seasons = @show.seasons.includes(:episodes).order(season_number: :asc)
            streams << turbo_stream.replace("show_details_#{@show.id}", partial: "shows/show_details", locals: { show: @show, seasons: @seasons })
          else
            # On index page - replace the row
            streams << turbo_stream.replace(@show, partial: "shows/show_row", locals: { show: @show })
          end
          streams << show_toast("Show refreshed successfully", type: "success")
          render(turbo_stream: streams)
        end
        format.html { redirect_to(@show, notice: "Show refreshed successfully") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render(turbo_stream: show_toast("Failed to refresh show", type: "error")) }
        format.html { redirect_to(@show, alert: "Failed to refresh show") }
      end
    end
  end

  def ignore
    @show.update!(ignored: true)

    respond_to do |format|
      format.turbo_stream do
        streams = []
        # If on index page, replace the row
        streams << if request.referer&.include?("/shows") && !request.referer&.include?("/shows/#{@show.id}")
          turbo_stream.replace(@show, partial: "shows/show_row", locals: { show: @show })
        else
          # On show page, replace the actions
          turbo_stream.replace("show_actions_#{@show.id}", partial: "shows/actions", locals: { show: @show })
        end
        streams << show_toast("Show ignored - use filter to hide", type: "success")
        render(turbo_stream: streams)
      end
      format.html { redirect_to(shows_path, notice: "Show ignored") }
    end
  end

  def unignore
    @show.update!(ignored: false)

    respond_to do |format|
      format.turbo_stream do
        streams = []
        # If on index page, replace the row
        streams << if request.referer&.include?("/shows") && !request.referer&.include?("/shows/#{@show.id}")
          turbo_stream.replace(@show, partial: "shows/show_row", locals: { show: @show })
        else
          # On show page, replace the actions
          turbo_stream.replace("show_actions_#{@show.id}", partial: "shows/actions", locals: { show: @show })
        end
        streams << show_toast("Show unignored", type: "success")
        render(turbo_stream: streams)
      end
      format.html { redirect_to(shows_path, notice: "Show unignored") }
    end
  end

  private

  def set_show
    @show = Show.find(params[:id])
  end
end
