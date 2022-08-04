require 'rails_helper'

RSpec.describe GameService::Connect, type: :service do

  let!(:game) { FactoryBot.create(:game) }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  describe 'connect the new user to the game board' do
    it 'check single user\'s connect to the board' do
      GameService.connect(user1)
      game = Game.new_games.first
      expect(Game.new_games.exists?).to be_truthy
      expect(game.users.ids).to be_empty
      expect(game.user_games.first).to an_instance_of(NilClass)
    end

    it 'check second user\'s connect to the board' do
      game.users << user1
      game.new_game
      GameService.connect(user2)
      game = Game.new_games.first
      expect(Game.new_games.exists?).to be_truthy
      expect(game.users.ids).not_to be_empty
      expect(game.user_games.first).to an_instance_of(UserGame)
    end
  end
end