# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "game_channel_#{params[:game_id]}" if params[:game_id].present?
  end

  def unsubscribed
    params
    stop_all_streams
  end

  def send_game(data)
    move = data['move'].gsub(/[^0-9]/, '').to_i
    user_id = data['user_id'].to_i
    game_id = data['game_id'].to_i
    GameService.playing(move, user_id, game_id) if GameService.opponent(game_id)
  end

  def withdraw_game
    game = Game.find_by(id: params[:game_id]) unless params[:game_id].blank?
    game.withdraw(game) if game.present?
  end

  def end_game
    game = Game.find_by(id: params[:game_id]) unless params[:game_id].blank?
    game.finish!(game, params[:user_id]) if game.present?
  end
end
