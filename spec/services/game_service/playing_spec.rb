require 'rails_helper'

RSpec.describe GameService::Playing, type: :service do
  let!(:game) { FactoryBot.create(:game) }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  describe 'check playing board' do
    it 'check single user\'s and update after 1st turn' do
      game = Game.new
      game.users << [user1, user2]
      @game = game.new_game
      GameService.playing(1, user1.id, game.id)
      expect(game.moves.select(&:box).empty?).to be_truthy
      expect(game.user_games.where(game_id: game.id, user_id: user1.id).first).to be_an_instance_of(UserGame)
      expect(game.user_games.where(game_id: game.id, user_id: user1.id).first.move_allowed?).to be_falsey
    end

    it 'second user\'s and one opponent, and update' do
      game = Game.new
      game.users << [user1, user2]
      @game = game.new_game
      GameService.playing(1, user1.id, game.id)
      expect(game.moves.select(&:box).empty?).to be_truthy
      expect(game.user_games.where(game_id: game.id, user_id: user1.id).first).to be_an_instance_of(UserGame)
      expect(game.user_games.where(game_id: game.id, user_id: user1.id).first.move_allowed?).to be_falsey
      GameService.playing(2, user2.id, game.id)
      expect(game.user_games.where(game_id: game.id, user_id: user2.id).first).to be_an_instance_of(UserGame)
      expect(game.user_games.where(game_id: game.id, user_id: user2.id).first.move_allowed?).to be_falsey
    end
  end

end