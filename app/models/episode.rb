# frozen_string_literal: true

class Episode < ApplicationRecord
  belongs_to :season
  has_one :show, through: :season

  validates :episode_number, presence: true, uniqueness: { scope: :season_id }

  scope :search_by_title, ->(query) { where("title LIKE ?", "%#{sanitize_sql_like(query)}%") if query.present? }
  scope :ordered_by_size_desc, -> { order(size_bytes: :desc) }

  after_destroy :update_season_totals
  after_save :update_season_totals

  private

  def update_season_totals
    season.update_totals!
  end
end
