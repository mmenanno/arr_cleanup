# frozen_string_literal: true

class Show < ApplicationRecord
  has_many :seasons, dependent: :destroy
  has_many :episodes, through: :seasons

  validates :title, presence: true
  validates :sonarr_id, presence: true, uniqueness: true

  scope :not_ignored, -> { where(ignored: false) }
  scope :with_ignored_option, ->(show_ignored) { show_ignored ? all : not_ignored }
  scope :with_remux, -> { where(contains_remux: true) }
  scope :search_by_title, ->(query) { where("title LIKE ?", "%#{sanitize_sql_like(query)}%") if query.present? }
  scope :ordered_by_size_desc, -> { order(total_size_bytes: :desc) }
  scope :ordered_by_title, -> { order(title: :asc) }
  scope :ordered_by_year, -> { order(year: :desc) }
end
