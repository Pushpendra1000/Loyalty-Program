# frozen_string_literal: true

# spec/models/transaction_spec.rb
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one(:loyalty_point) }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:currency) }
  end

  describe 'callbacks' do
    let(:user) { FactoryBot.create(:user) }
    let(:transaction) { FactoryBot.create(:transaction, user:, amount: 1000, currency: 'us') }

    it 'creates a loyalty point after transaction is created' do
      expect { transaction.save }.to change { LoyaltyPoint.count }.by(1)
    end

    it 'assigns the correct number of points for USD transactions' do
      transaction.save
      loyalty_point = transaction.loyalty_point
      expect(loyalty_point.received_points).to eq(100)
    end

    it 'assigns the correct number of points for non-USD transactions' do
      transaction = FactoryBot.create(:transaction, user:, amount: 1000, currency: 'inr')
      loyalty_point = transaction.loyalty_point
      expect(loyalty_point.received_points).to eq(200)
    end

    it 'sets the valid till date correctly' do
      transaction.save
      loyalty_point = transaction.loyalty_point
      expect(loyalty_point.valid_till).to eq(Date.today + 1.year)
    end
  end

  describe '#assign_points' do
    let(:user) { FactoryBot.create(:user) }

    it 'creates a loyalty_point with correct points and valid_till' do
      transaction = FactoryBot.create(:transaction, amount: 1000, currency: 'us', user:)
      transaction.assign_points
      expect(transaction.loyalty_point).to be_present
      expect(transaction.loyalty_point.received_points).to eq(100)
      expect(transaction.loyalty_point.valid_till).to eq(Date.today + 1.year)
    end

    it 'does not create a loyalty_point if received_points is zero' do
      transaction = FactoryBot.create(:transaction, amount: 0, currency: 'us', user:)
      transaction.assign_points
      expect(transaction.loyalty_point).to be_nil
    end
  end

  describe '#received_points' do
    let(:user) { FactoryBot.create(:user) }

    it 'calculates received points correctly for USD currency' do
      transaction = FactoryBot.create(:transaction, amount: 1000, currency: 'us', user:)
      expect(transaction.received_points).to eq(10)
    end

    it 'calculates received points correctly for non-USD currency' do
      transaction = FactoryBot.create(:transaction, amount: 1000, currency: 'eur', user:)
      expect(transaction.received_points).to eq(20)
    end
  end
end
# rubocop:enable Metrics/BlockLength
