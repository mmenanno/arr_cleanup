# frozen_string_literal: true

class CreateJobErrors < ActiveRecord::Migration[8.0]
  def change
    create_table(:job_errors) do |t|
      t.string(:service_type, null: false)
      t.string(:error_class)
      t.text(:error_message)
      t.datetime(:occurred_at, null: false)

      t.timestamps
    end

    add_index(:job_errors, :service_type)
    add_index(:job_errors, :occurred_at)
  end
end
