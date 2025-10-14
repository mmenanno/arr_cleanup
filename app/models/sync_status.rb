# frozen_string_literal: true

class SyncStatus < ApplicationRecord
  STATUSES = ["queued", "running", "complete", "error"].freeze

  validates :service_type, presence: true, uniqueness: true, inclusion: { in: ["radarr", "sonarr"] }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Store the count from last successful sync
  attribute :last_sync_count, :integer, default: 0

  scope :radarr, -> { find_or_initialize_by(service_type: "radarr") }
  scope :sonarr, -> { find_or_initialize_by(service_type: "sonarr") }

  class << self
    def for_service(service_type)
      find_or_initialize_by(service_type: service_type.to_s)
    end
  end

  def broadcast_update
    # For running state, only update text and progress bar (not the spinner)
    if status == "running" && progress_total > 0
      # Update message text only
      Turbo::StreamsChannel.broadcast_update_to(
        "sync_status_#{service_type}",
        target: "sync_message_#{service_type}",
        html: message,
      )

      # Update progress bar width only
      Turbo::StreamsChannel.broadcast_update_to(
        "sync_status_#{service_type}",
        target: "sync_progress_bar_#{service_type}",
        html: %(<div id="sync_progress_bar_#{service_type}" class="bg-indigo-600 h-1.5 rounded-full transition-all duration-300" style="width: #{progress_percentage}%"></div>),
      )
    else
      # For other states (queued, complete, error), replace entire content
      Turbo::StreamsChannel.broadcast_replace_to(
        "sync_status_#{service_type}",
        target: "sync_status_content_#{service_type}",
        partial: "dashboard/sync_status_content",
        locals: { service_type:, sync_status: self },
      )
    end
  end

  def progress_percentage
    return 0 if progress_total.zero?

    ((progress_current.to_f / progress_total) * 100).round
  end
end
