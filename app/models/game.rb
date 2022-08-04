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
    player1 = board_moves.cross.pluck(:position).sort
    player2 = board_moves.nought.pluck(:position).sort

    if WINNING_COMBINATIONS.include?(player1)
      user = user_games.cross.user
      return [user, true]
    end

    if WINNING_COMBINATIONS.include?(player2)
      user = user_games.nought.user
      return [user, true]
    end
    [nil, false]
  end

  def finish!(winner_id = nil)
    finilised_result(winner_id)
    finished!
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

  def new_game
    [*1..9].each do |i|
      moves.new(position: i)
    end
    save! && self
  end

  def withdraw!
    ActiveRecord::Base.transaction do
      with_draw! if new_game? || started?
    end
    user_games.update_all(result: UserGame::RESULTS[:tie])
    ActionCable.server.broadcast("game_channel_#{id}",
                                 { action: 'with_draw',
                                   result: attributes.slice(*GAME_STATUS) })
  end

  private

  def finilised_result(winner_id = nil)
    ActiveRecord::Base.transaction do
      if winner_id.present?
        user_games.find_by(user_id: winner_id, game_id: id).update_attributes(result: UserGame::RESULTS[:win])
        user_games.where(game_id: id).where.not(user_id: winner_id).update_all(result: UserGame::RESULTS[:lost])
      else
        user_games.update_all(result: UserGame::RESULTS[:tie])
      end
    end
  end
end
