# frozen_string_literal: true

class CreateMoves < ActiveRecord::Migration[5.2]
  def change
    create_table :moves do |t|
      t.integer :box
      t.integer :position
      t.references :game, foreign_key: true

      t.timestamps
    end
  end
end
