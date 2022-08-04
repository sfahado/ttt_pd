# frozen_string_literal: true

class Game < ApplicationRecord
  has_many :user_games
  has_many :users, through: :user_games
  has_many :moves

  STATUSES ||= {
    new_game: 1,
    started: 2,
    with_draw: 3,
    finished: 4
  }.freeze

  MOVES ||= {
    cross: 1,
    nought: 2
  }.freeze

  GAME_STATUS = ['status'].freeze

  enum status: STATUSES

  scope :successful_games, -> { where.not(status: %w[new_game started]) }
  scope :new_games, -> { where(status: 'new_game') }

  accepts_nested_attributes_for :moves

  WINNING_COMBINATIONS = [
    [1, 2, 3], [4, 5, 6], [7, 8, 9],
    [1, 4, 7], [2, 5, 8], [3, 6, 9],
    [1, 5, 9], [3, 5, 7]
  ].freeze

  def check_winner
    board_moves = moves.filled
    player1 = board_moves.cross.pluck(:position)
    player2 = board_moves.nought.pluck(:position)

    if WINNING_COMBINATIONS.include?(player1)
      user = user_games.cross.user.name
      return [user, true]
    end

    if WINNING_COMBINATIONS.include?(player2)
      user = user_games.nought.user.name
      return [user, true]
    end
    [nil, false]
  end

  def new_game
    [*1..9].each do |i|
      moves.new(position: i)
    end
    save! && self
  end

  def withdraw!(game)
    game.with_draw! if game.new_game? || game.started?

    ActionCable.server.broadcast("game_channel_#{game.id}",
                                 { action: 'with_draw',
                                   result: game.attributes.slice(*GAME_STATUS) })
  end

  def finish!(game)
    game.finished!
  end

  def game_board
    moves.map do |move|
      {
        id: move.id,
        position: move.position,
        game_id: move.game_id,
        box: move.box
      }
    end.as_json
  end
end
