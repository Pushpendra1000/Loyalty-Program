# frozen_string_literal: true

# spec/models/loyalty_point_spec.rb
require 'rails_helper'

RSpec.describe LoyaltyPoint, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:user_transaction).class_name('Transaction').with_foreign_key('transaction_id').optional }
  end

  describe 'scopes' do
    describe '.monthly_points' do
      let(:user) { FactoryBot.create(:user) }
      let!(:points) { FactoryBot.create(:loyalty_point, received_points: 100, user:) }
      it 'calculates the sum of received_points for each month' do
        result = LoyaltyPoint.monthly_points
        expect(result).to include(points)
      end
    end

    describe '.unexpired' do
      let!(:unexpired_point) { FactoryBot.create(:loyalty_point, expired: false) }
      let!(:expired_point) { FactoryBot.create(:loyalty_point, expired: true) }

      it 'includes only unexpired loyalty points' do
        expect(LoyaltyPoint.unexpired).to include(unexpired_point)
      end

      it 'does not include expired loyalty points' do
        expect(LoyaltyPoint.unexpired).not_to include(expired_point)
      end
    end
  end
end
