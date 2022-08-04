# frozen_string_literal: true

class UserGame < ApplicationRecord
  belongs_to :game
  belongs_to :user

  before_create :assign_the_game_symbol

  RESULTS ||= {
    win: 1,
    lost: 2,
    tie: 3,
    starting: 4
  }.freeze

  MOVES ||= {
    cross: 1,
    nought: 2
  }.freeze

  enum result: RESULTS
  enum symbol: MOVES

  scope :starting_games, -> { where(result: 'starting') }
  scope :cross, -> { find_by(symbol: MOVES[:cross]) }
  scope :nought, -> { find_by(symbol: MOVES[:nought]) }

  def status_changed_to_new_game?
    game.status.eql?(['new_game'])
  end

  def assign_the_game_symbol
    self.symbol = if game.user_games.count.zero?
                    MOVES[:cross]
                  else
                    MOVES[:nought]
                  end
  end
end
