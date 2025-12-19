# frozen_string_literal: true

class SeasonsController < ApplicationController
  before_action :set_show
  before_action :set_season

  def show
    @query = params[:q]
    episodes = @season.episodes
    episodes = episodes.search_by_title(@query) if @query.present?
    episodes = episodes.ordered_by_size_desc

    @pagy, @episodes = pagy(episodes, limit: 50)
  end

  private

  def set_show
    @show = Show.find(params[:show_id])
  end

  def set_season
    @season = @show.seasons.find(params[:id])
  end
end
