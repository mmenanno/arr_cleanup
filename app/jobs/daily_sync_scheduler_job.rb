# frozen_string_literal: true

class DailySyncSchedulerJob < ApplicationJob
  queue_as :default

  def perform
    SyncRadarrJob.perform_later
    SyncSonarrJob.perform_later
    Rails.logger.info("Daily sync jobs scheduled")
  end
end
