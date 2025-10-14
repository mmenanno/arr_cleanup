# frozen_string_literal: true

class JobError < ApplicationRecord
  validates :service_type, presence: true, inclusion: { in: ["radarr", "sonarr"] }
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc).limit(10) }
  scope :for_service, ->(service_type) { where(service_type:) }
end
