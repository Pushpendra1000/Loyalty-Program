# frozen_string_literal: true

# spec/models/reward_spec.rb
require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    describe '.unclaimed' do
      let!(:claimed_reward) { FactoryBot.create(:reward, claimed_at: Time.now) }
      let!(:unclaimed_reward) { FactoryBot.create(:reward) }

      it 'includes rewards that are unclaimed' do
        expect(Reward.unclaimed).to include(unclaimed_reward)
      end

      it 'does not include rewards that are claimed' do
        expect(Reward.unclaimed).not_to include(claimed_reward)
      end
    end
  end
end
