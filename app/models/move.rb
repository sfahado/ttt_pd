# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :game
  validates :position, presence: true,
                       numericality: { only_integer: true, less_than: 10,
                                       greater_than: 0, message: 'Position limit exceeded' }

  scope :filled, -> { where(box: [1, 2]) }
  scope :cross, -> { where(box: 1) }
  scope :nought, -> { where(box: 2) }
  after_update_commit :check_winner

  def check_winner
    winner = false
    tie = false
    user, winner = game.check_winner if game.moves.filled.count >= 4
    tie = (game.moves.filled.count >= 9)
    if winner || tie
      ActionCable.server.broadcast("game_channel_#{game.id}",
                                   { action: 'result', winner: winner, tie: tie, user: user,
                                     game_id: game.id, path: '/users/new' })
    end
  end
end
