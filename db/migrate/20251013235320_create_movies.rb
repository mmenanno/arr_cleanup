# frozen_string_literal: true

class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table(:movies) do |t|
      t.string(:title, null: false)
      t.integer(:year)
      t.integer(:tmdb_id)
      t.integer(:radarr_id, null: false)
      t.string(:file_path)
      t.bigint(:size_bytes, limit: 8)
      t.string(:quality_profile)
      t.string(:quality)
      t.boolean(:is_remux, default: false, null: false)
      t.boolean(:ignored, default: false, null: false)
      t.datetime(:last_refreshed_at)

      t.timestamps
    end

    add_index(:movies, :radarr_id, unique: true)
    add_index(:movies, :title)
    add_index(:movies, :size_bytes)
    add_index(:movies, :is_remux)
    add_index(:movies, :ignored)
  end
end
