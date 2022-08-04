# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  subject { FactoryBot.create(:game) }
  let!(:games_list) { FactoryBot.create_list(:game, 5) }
  let(:user1) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }

  describe 'Associations' do
    it { is_expected.to have_many(:user_games) }
    it { is_expected.to have_many(:users).through(:user_games) }
    it { is_expected.to have_many(:moves) }
  end

  describe 'methods' do
    it { expect(subject).to respond_to(:check_winner) }
    it { expect(subject).to respond_to(:new_game) }
    it { expect(subject).to respond_to(:withdraw!) }
    it { expect(subject).to respond_to(:finish!) }
    it { expect(subject).to respond_to(:game_board) }
  end
  describe 'Validations' do
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is  valid without status' do
      subject.status = nil
      expect(subject).to be_valid
    end
  end

  context 'enum in game' do
    it { should define_enum_for(:status) }
    it { should define_enum_for(:status).with_values({ new_game: 1, started: 2, with_draw: 3, finished: 4 }) }
  end

  describe 'scopes' do
    it 'must have correct games' do
      expect(Game.new_games.count).to eq(games_list.count + 1)
      expect(Game.successful_games.count).to eq(0)
    end
    it 'must exclude finished games' do
      Game.last.finished!
      expect(Game.new_games.count).not_to eq(games_list.count + 1)
      expect(Game.successful_games.count).to eq(1)
    end
  end

  describe 'instance methods' do
    context '.new_game' do
      it 'must exclude finished games' do
        game = Game.new.new_game
        expect(game.moves.count).to eq(9)
        expect(game.moves.first).to be_a_kind_of(Move)
      end

      it 'must exclude finished games' do
        game = Game.new.new_game
        expect(game.moves.count).to eq(9)
        expect(game.moves.first).to be_a_kind_of(Move)
      end
    end
    describe 'game #instance_methods' do
      context '.game_board' do
        it 'must have correct data' do
          game = Game.new.new_game.game_board
          expect(game).to be_an_instance_of(Array)
          expect(game[0]).to be_an_instance_of(Hash)
          expect(game[0]['id']).to be_truthy
          expect(game[0]['id']).to be_a_kind_of(Integer)
          expect(game[0]['position']).to be_truthy
          expect(game[0]['position']).to be_a_kind_of(Integer)
          expect(game[0]['game_id']).to be_truthy
          expect(game[0]['game_id']).to be_a_kind_of(Integer)
          expect(game[0]['box']).to be_a_kind_of(NilClass)
        end
      end
      context '.check_winner' do
        before do
          game = Game.new
          game.users << [user1, user2]
          @game = game.new_game
        end
        it 'when board is empty it is failed to fetch winner' do
          expect(@game.users.count).to eq(2)
          expect(@game.users.first).to be_a(User)
          expect(@game.check_winner.first).to be_a(NilClass)
          expect(@game.check_winner.last).to be_falsey
        end

        it 'when board is filled with cross' do
          @game.moves.order('created_at DESC').limit(3).update_all(box: 1)
          expect(@game.users.count).to eq(2)
          expect(@game.users.first).to be_a(User)
          expect(@game.check_winner.first).to be_a(User)
          expect(@game.check_winner.last).to be_truthy
        end

        it 'when board is filled with nought' do
          @game.moves.order('created_at ASC').limit(3).update_all(box: 2)
          expect(@game.users.count).to eq(2)
          expect(@game.users.first).to be_a(User)
          expect(@game.check_winner.first).to be_a(User)
          expect(@game.check_winner.last).to be_truthy
        end

        it 'when board is filled with either cross/nought' do
          Game::WINNING_COMBINATIONS.each do |win|
            @game.moves.order('created_at DESC').update_all(box: nil)
            @game.moves.where(position: win).update_all(box: [1, 2].sample)
            expect(@game.users.count).to eq(2)
            expect(@game.users.first).to be_a(User)
            expect(@game.check_winner.first).to be_a(User)
            expect(@game.check_winner.last).to be_truthy
          end
        end
      end

      context '.withdraw!' do
        before do
          game = Game.new
          game.users << [user1, user2]
          @game = game.new_game
        end
        it 'change the status' do
          @game.withdraw!
          expect(@game.status).to be_eql('with_draw')
        end

        it 'change the user-states' do
          @game.withdraw!
          expect(@game.status).to be_eql('with_draw')
          expect(@game.user_games.pluck(:result).uniq).to be_eql(['tie'])
        end
      end

      context '.finish!' do
        before do
          game = Game.new
          game.users << [user1, user2]
          @game = game.new_game
        end

        it 'change the status, when game is finished' do
          @game.finish!(user1.id)
          expect(@game.status).to be_eql('finished')
        end

        it 'change the user-states' do
          @game.finish!(user2.id)
          expect(@game.user_games.find_by!(user_id: user2.id).result).to be_eql('win')
          expect(@game.user_games.where.not(user_id: user2.id).first.result).to be_eql('lost')
        end
      end
    end
  end
end
