# frozen_string_literal: true

namespace :sync do
  desc "Clear stuck sync status records"
  task clear_status: :environment do
    SyncStatus.delete_all
    puts "Cleared all sync status records"
  end

  desc "Show current sync status"
  task status: :environment do
    SyncStatus.find_each do |status|
      puts "#{status.service_type}: #{status.status} - #{status.message} (#{status.progress_current}/#{status.progress_total})"
    end
  end
end
