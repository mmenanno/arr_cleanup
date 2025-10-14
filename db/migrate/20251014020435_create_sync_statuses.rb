# frozen_string_literal: true

class CreateSyncStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table(:sync_statuses) do |t|
      t.string(:service_type, null: false)
      t.string(:status, null: false)
      t.integer(:progress_current, default: 0)
      t.integer(:progress_total, default: 0)
      t.string(:message)
      t.datetime(:started_at)
      t.datetime(:completed_at)

      t.timestamps
    end

    add_index(:sync_statuses, :service_type, unique: true)
    add_index(:sync_statuses, :status)
  end
end
