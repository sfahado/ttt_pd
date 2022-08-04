# frozen_string_literal: true

module GameService
  class Playing < ApplicationService
    attr_accessor :game
    attr_reader :move, :user_id, :game_id, :user_game

    # rubocop:disable Lint/MissingSuper
    def initialize(move, user_id, game_id)
      @move = move
      @user_id = user_id
      @game_id = game_id
    end
    # rubocop:enable Lint/MissingSuper

    def perform
      set_game
      game_playing
    end

    protected

    def check_turn
      @user_game = game.user_games.find_by(user_id: user_id, game_id: game_id)
      @user_game.move_allowed
    end

    def set_game
      @game = Game.find_by(id: game_id)
    end

    def game_playing
      if check_turn && game.moves.find_by(position: move).box.nil?
        game.moves.find_by(position: move).update_attributes(box: Game::MOVES[user_game.symbol.to_sym])
        user_states(game.user_games, user_id)
        ActionCable.server.broadcast("game_channel_#{game.id}", { game: game.game_board.as_json,
                                                                  action: 'game_start' })
      else
        ActionCable.server.broadcast("game_channel_#{game.id}", { game: game.game_board.as_json,
                                                                  action: 'wrong_turn' })
      end
    end

    private

    def user_states(players, current_user)
      players.where(user_id: current_user).first.toggle!(:move_allowed)
      players.where.not(user_id: current_user).first.toggle!(:move_allowed)
    end
  end
end
