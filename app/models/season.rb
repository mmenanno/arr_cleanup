# frozen_string_literal: true

class Season < ApplicationRecord
  belongs_to :show
  has_many :episodes, dependent: :destroy

  validates :season_number, presence: true, uniqueness: { scope: :show_id }

  def update_totals!
    update!(
      total_size_bytes: episodes.sum(:size_bytes),
      contains_remux: episodes.exists?(is_remux: true),
    )
  end
end
