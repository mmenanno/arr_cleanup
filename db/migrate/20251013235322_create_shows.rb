# frozen_string_literal: true

class CreateShows < ActiveRecord::Migration[8.0]
  def change
    create_table(:shows) do |t|
      t.string(:title, null: false)
      t.integer(:year)
      t.integer(:tvdb_id)
      t.integer(:sonarr_id, null: false)
      t.bigint(:total_size_bytes, limit: 8, default: 0)
      t.boolean(:contains_remux, default: false, null: false)
      t.boolean(:ignored, default: false, null: false)
      t.datetime(:last_refreshed_at)

      t.timestamps
    end

    add_index(:shows, :sonarr_id, unique: true)
    add_index(:shows, :title)
    add_index(:shows, :total_size_bytes)
    add_index(:shows, :contains_remux)
    add_index(:shows, :ignored)
  end
end
