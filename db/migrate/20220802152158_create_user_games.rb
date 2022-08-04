# frozen_string_literal: true

class CreateUserGames < ActiveRecord::Migration[5.2]
  def change
    create_table :user_games do |t|
      t.integer :result, default: 4
      t.references :game, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :symbol, default: 1
      t.boolean :move_allowed, default: false

      t.timestamps
    end
  end
end
