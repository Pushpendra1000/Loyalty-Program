# frozen_string_literal: true

# spec/models/user_spec.rb
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:transactions) }
    it { should have_many(:loyalty_points) }
    it { should have_many(:rewards) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).on(:create) }
    it { should validate_presence_of(:email).on(:create) }
    it { should validate_presence_of(:birthday).on(:create) }
    it { should validate_presence_of(:password).on(:create) }

    it { should validate_confirmation_of(:password) }
    it { should validate_length_of(:password).is_at_least(6).is_at_most(16) }
    it { should allow_value('Password123').for(:password).on(:create) }
    it {
      should_not allow_value('Password!123').for(:password).on(:create).with_message('only allows letters and numbers')
    }
  end

  describe 'scopes' do
    describe '.birthday_month' do
      let!(:user_in_birthday_month) { FactoryBot.create(:user, name: 'test_1', birthday: Date.today) }
      let!(:user_not_in_birthday_month) { FactoryBot.create(:user, name: 'test_2', birthday: Date.today - 1.month) }
      it 'includes users whose birthday is in the current month' do
        expect(User.birthday_month).to include(user_in_birthday_month)
      end

      it 'does not include users whose birthday is not in the current month' do
        expect(User.birthday_month).not_to include(user_not_in_birthday_month)
      end
    end
  end

  describe '#available_points' do
    let(:user) { FactoryBot.create(:user) }
    let!(:unexpired_loyalty_points) do
      create(:loyalty_point, user:, received_points: 10, valid_till: Date.today + 1.month)
    end
    let!(:expired_loyalty_points) do
      create(:loyalty_point, user:, received_points: 20, valid_till: Date.today - 1.day, expired: true)
    end

    it 'sums only unexpired loyalty points' do
      expect(user.available_points).to eq(10)
    end
  end
end
# rubocop:enable Metrics/BlockLength
