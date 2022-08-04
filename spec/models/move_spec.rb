# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Move, type: :model do
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  subject { FactoryBot.create(:move, :with_game) }

  describe 'Associations' do
    it { is_expected.to belong_to(:game) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :position }
  end

  context '.check_board_winner' do
    before do
      game = Game.new
      game.users << [user1, user2]
      @game = game.new_game
    end
    it 'when board is filled with correct combination' do
      Game::WINNING_COMBINATIONS.sample.each.with_index(1) do |i, j|
        @game.moves.find_by(position: i).update_attributes(box: Game::MOVES[:cross])
        if j % 3 == 0
          expect(@game.check_winner.first).to be_a(User)
          expect(@game.check_winner.last).to be_truthy
        end
      end
    end
  end
end
