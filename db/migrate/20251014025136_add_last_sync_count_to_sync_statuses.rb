# frozen_string_literal: true

class AddLastSyncCountToSyncStatuses < ActiveRecord::Migration[8.0]
  def change
    add_column(:sync_statuses, :last_sync_count, :integer, default: 0)
  end
end
