# frozen_string_literal: true

FactoryBot.define do
  factory :move do
    position { 1 }

    trait :with_game do
      before(:create) do |u|
        u.game = create(:game)
      end
    end
  end
end
