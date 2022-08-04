# frozen_string_literal: true

module GameService
  class Opponent < ApplicationService
    attr_reader :game_id
    attr_accessor :game

    # rubocop:disable Lint/MissingSuper
    def initialize(game_id)
      @game_id = game_id
    end
    # rubocop:enable Lint/MissingSuper

    def perform
      set_game && check_opponent
    end

    protected

    def set_game
      @game = Game.find_by(id: game_id)
    end

    def check_opponent
      return true if game.user_games.starting_games.where(game_id: game_id).count >= 2

      ActionCable.server.broadcast("game_channel_#{game.id}", { action: 'connected' })
      false
    end
  end
end
