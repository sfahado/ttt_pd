# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { described_class.new }

  context 'validations' do
    it { is_expected.to allow_value('namee').for(:name) }
    it { is_expected.to allow_value('name@t').for(:name) }
    it { is_expected.not_to allow_value('').for(:name) }
    %w[user_fo THE_USER first.lastfoo.jp].each do |name|
      it { is_expected.to allow_value(name).for(:name) }
    end
    it do
      should validate_length_of(:name).is_at_least(3).is_at_most(50)
    end
  end
  let(:user) { FactoryBot.create(:user) }

  context 'validations' do
    it 'is valid when user is created' do
      expect(user).to be_valid
    end

    it 'is invalid when name is empty' do
      user1 = User.new(name: '')
      expect(user1).to be_invalid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:user_games) }
    it { is_expected.to have_many(:games).through(:user_games) }
  end
end
