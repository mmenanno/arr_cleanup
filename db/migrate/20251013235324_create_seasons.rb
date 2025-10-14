# frozen_string_literal: true

class CreateSeasons < ActiveRecord::Migration[8.0]
  def change
    create_table(:seasons) do |t|
      t.references(:show, null: false, foreign_key: true)
      t.integer(:season_number, null: false)
      t.bigint(:total_size_bytes, limit: 8, default: 0)
      t.boolean(:contains_remux, default: false, null: false)

      t.timestamps
    end

    add_index(:seasons, [:show_id, :season_number], unique: true)
    add_index(:seasons, :total_size_bytes)
  end
end
