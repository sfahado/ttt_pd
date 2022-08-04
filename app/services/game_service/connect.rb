# frozen_string_literal: true

module GameService
  class Connect < ApplicationService
    attr_accessor :user

    # rubocop:disable Lint/MissingSuper
    def initialize(user)
      @user = user
    end
    # rubocop:enable Lint/MissingSuper

    def perform
      ensure_game_connection
    end

    protected

    def ensure_game_connection
      return nil unless Game.new_games.exists?

      game = Game.new_games.first
      game.users << user
      game.started!
      game.user_games.first.toggle!(:move_allowed) if game.user_games.present?
      game
    end
  end
end
