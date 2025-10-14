# frozen_string_literal: true

class CreateEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table(:episodes) do |t|
      t.references(:season, null: false, foreign_key: true)
      t.integer(:episode_number, null: false)
      t.string(:title)
      t.string(:file_path)
      t.bigint(:size_bytes, limit: 8)
      t.string(:quality_profile)
      t.string(:quality)
      t.boolean(:is_remux, default: false, null: false)

      t.timestamps
    end

    add_index(:episodes, [:season_id, :episode_number], unique: true)
    add_index(:episodes, :title)
    add_index(:episodes, :size_bytes)
  end
end
