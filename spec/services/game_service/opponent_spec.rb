require 'rails_helper'

RSpec.describe GameService::Opponent, type: :service do
  let!(:game) { FactoryBot.create(:game) }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  describe 'check opponents' do
    it 'check single user\'s and no opponent' do
      connected = GameService.opponent(game.id)
      expect(connected).to be_falsey
      expect(game.users.ids).to be_empty
      expect(game.user_games.first).to an_instance_of(NilClass)
    end

    it 'second user\'s and one opponent' do
      game.users << user1
      game.new_game
      connected = GameService.opponent(game.id)
      expect(connected).to be_falsey
      expect(game.users.ids).not_to be_empty
      expect(game.user_games.first).to an_instance_of(UserGame)
    end
  end
end