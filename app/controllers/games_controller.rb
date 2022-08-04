# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :get_user, only: %i[new create update]

  # Renders game board for new joined user
  # @controller_action_param :user [User]
  def new
    @game = GameService.connect(@user)
    if @game.blank?
      @game = Game.new
      @game.users << @user
      @game = @game.new_game
    end
    ActionCable.server.broadcast("game_channel_#{@game.id}", { game: @game.game_board, action: 'new_game' })
    render 'show'
  end

  def index; end

  private

  def get_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end
end
