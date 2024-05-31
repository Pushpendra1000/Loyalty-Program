# frozen_string_literal: true

# spec/services/reward_service_spec.rb
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe RewardService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe '#birthday_month_reward' do
    it 'creates a one-time reward for the user' do
      expect { service.birthday_month_reward }.to change { user.rewards.count }.by(1)
      reward = user.rewards.last
      expect(reward.name).to eq(I18n.t('reward.birthday_month_reward.title'))
      expect(reward.description).to eq(I18n.t('reward.birthday_month_reward.description'))
    end
  end

  describe '#monthly_spent_reward' do
    context 'when user has more than 100 monthly points' do
      before do
        allow(user.loyalty_points).to receive_message_chain(:monthly_points, :sum).and_return(150)
      end

      it 'creates an unlimited time reward for the user' do
        expect { service.monthly_spent_reward }.to change { user.rewards.count }.by(1)
        reward = user.rewards.last
        expect(reward.name).to eq(I18n.t('reward.monthly_spend_reward.title'))
        expect(reward.description).to eq(I18n.t('reward.monthly_spend_reward.description'))
      end
    end

    context 'when user has 100 or fewer monthly points' do
      before do
        allow(user.loyalty_points).to receive_message_chain(:monthly_points, :sum).and_return(50)
      end

      it 'does not create a reward for the user' do
        expect { service.monthly_spent_reward }.not_to(change { user.rewards.count })
      end
    end
  end

  describe '#quarterly_spent_reward' do
    context 'when user has spent more than 2000 in the last quarter' do
      before do
        allow(user.transactions).to receive_message_chain(:quarterly_spend, :sum).and_return(2500)
      end

      it 'creates 100 loyalty points for the user' do
        expect { service.quarterly_spent_reward }.to change { user.loyalty_points.count }.by(1)
        points = user.loyalty_points.last
        expect(points.received_points).to eq(100)
      end
    end

    context 'when user has spent 2000 or less in the last quarter' do
      before do
        allow(user.transactions).to receive_message_chain(:quarterly_spend, :sum).and_return(1500)
      end

      it 'does not create loyalty points for the user' do
        expect { service.quarterly_spent_reward }.not_to(change { user.loyalty_points.count })
      end
    end
  end

  describe '#rebate_on_transactions' do
    context 'when user has 10 or more transactions over 100' do
      let(:transactions) { create_list(:transaction, 10, user:, amount: 150) }

      before do
        allow(user.transactions).to receive(:where).and_return(transactions)
      end

      it 'creates a one-time rebate reward for the user' do
        expect { service.rebate_on_transactions }.to change { user.rewards.count }.by(1)
        reward = user.rewards.last
        rebate_amount = transactions.sum { |t| t.amount * 0.05 }
        expect(reward.name).to eq(I18n.t('reward.rebate_on_transactions.title'))
        expect(reward.description).to include(I18n.t('reward.rebate_on_transactions.description',
                                                     rebate_amount:))
      end
    end

    context 'when user has fewer than 10 transactions over 100' do
      let(:transactions) { create_list(:transaction, 5, user:, amount: 150) }

      before do
        allow(user.transactions).to receive(:where).and_return(transactions)
      end

      it 'does not create a rebate reward for the user' do
        expect { service.rebate_on_transactions }.not_to(change { user.rewards.count })
      end
    end
  end

  describe '#movie_ticket_reward' do
    context 'when user has spent more than 1000 in 60 days from the first transaction' do
      let(:first_transaction) { create(:transaction, user:, amount: 500, created_at: 30.days.ago) }
      let!(:transactions) { create_list(:transaction, 2, user:, amount: 600, created_at: 20.days.ago) }

      before do
        allow(user.transactions).to receive(:exists?).and_return(true)
        allow(user.transactions).to receive(:first).and_return(first_transaction)
        allow(user.transactions).to receive(:where).and_return(transactions)
      end

      it 'creates a one-time movie ticket reward for the user' do
        expect { service.movie_ticket_reward }.to change { user.rewards.count }.by(1)
        reward = user.rewards.last
        transactions.sum { |t| t.amount * 0.05 }
        expect(reward.name).to eq(I18n.t('reward.movie_ticket_reward.title'))
        expect(reward.description).to eq(I18n.t('reward.movie_ticket_reward.description'))
      end
    end

    context 'when user has spent 1000 or less in 60 days from the first transaction' do
      let(:first_transaction) { create(:transaction, user:, amount: 500, created_at: 30.days.ago) }
      let!(:transactions) { create_list(:transaction, 2, user:, amount: 200, created_at: 20.days.ago) }

      before do
        allow(user.transactions).to receive(:exists?).and_return(true)
        allow(user.transactions).to receive(:first).and_return(first_transaction)
        allow(user.transactions).to receive(:where).and_return(transactions)
      end

      it 'does not create a movie ticket reward for the user' do
        expect { service.movie_ticket_reward }.not_to(change { user.rewards.count })
      end
    end
  end

  describe '#upgrade_user' do
    context 'when user has 5000 or more loyalty points in the last 2 years' do
      before do
        allow(user.loyalty_points).to receive(:where).and_return(double(sum: 6000))
        allow(user).to receive(:platinum!)
      end

      it 'upgrades the user to platinum' do
        expect(user).to receive(:platinum!)
        service.upgrade_user
      end
    end

    context 'when user has between 1000 and 4999 loyalty points in the last 2 years' do
      before do
        allow(user.loyalty_points).to receive(:where).and_return(double(sum: 3000))
        allow(user).to receive(:gold!)
      end

      it 'upgrades the user to gold and gives an airport lounge reward' do
        expect(user).to receive(:gold!)
        expect { service.upgrade_user }.to change { user.rewards.count }.by(1)
        reward = user.rewards.last
        expect(reward.name).to eq(I18n.t('reward.airport_lounge_reward.title'))
        expect(reward.description).to eq(I18n.t('reward.airport_lounge_reward.description'))
      end
    end

    context 'when user has fewer than 1000 loyalty points in the last 2 years' do
      before do
        allow(user.loyalty_points).to receive(:where).and_return(double(sum: 500))
      end

      it 'does not upgrade the user' do
        expect(user).not_to receive(:platinum!)
        expect(user).not_to receive(:gold!)
        service.upgrade_user
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
