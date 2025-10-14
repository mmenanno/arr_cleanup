# frozen_string_literal: true

class BaseSyncJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomial, attempts: 3

  def perform
    start_sync
    sync_data
    complete_sync
  rescue StandardError => e
    error_sync(e)
    raise
  end

  protected

  def sync_data
    raise NotImplementedError, "Subclasses must implement sync_data"
  end

  def service_type
    raise NotImplementedError, "Subclasses must implement service_type"
  end

  def start_sync
    sync_status.update!(
      status: "running",
      started_at: Time.current,
      progress_current: 0,
      progress_total: 0,
      message: "Starting sync...",
    )
    sync_status.broadcast_update
  end

  def update_progress(current, total, message: nil)
    sync_status.update!(
      progress_current: current,
      progress_total: total,
      message: message || "Syncing #{current}/#{total}...",
    )
    sync_status.broadcast_update if current % 5 == 0 || current == total # Broadcast every 5 items
  end

  def complete_sync
    update_last_synced_at

    # Store the total count from this sync
    final_count = sync_status.progress_total

    sync_status.update!(
      status: "complete",
      completed_at: Time.current,
      last_sync_count: final_count,
      message: "Synced #{final_count} #{"item".pluralize(final_count)}",
    )
    sync_status.broadcast_update
  end

  def error_sync(error)
    Rails.logger.error("#{self.class.name} failed: #{error.message}")

    # Log the error
    JobError.create!(
      service_type: service_type.to_s,
      error_class: error.class.name,
      error_message: error.message,
      occurred_at: Time.current,
    )

    sync_status.update!(
      status: "error",
      completed_at: Time.current,
      message: "Sync failed: #{error.message}",
    )
    sync_status.broadcast_update
  end

  def update_last_synced_at
    setting = AppSetting.instance
    case service_type
    when :radarr
      setting.update!(radarr_last_synced_at: Time.current)
    when :sonarr
      setting.update!(sonarr_last_synced_at: Time.current)
    end
  end

  def sync_status
    @sync_status ||= SyncStatus.for_service(service_type)
  end

  def app_settings
    @app_settings ||= AppSetting.instance
  end
end
