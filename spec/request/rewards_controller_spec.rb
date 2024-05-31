# frozen_string_literal: true

# spec/requests/rewards_controller_spec.rb
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe RewardsController, type: :request do
  before(:each) do
    @user = FactoryBot.create(:user)
    @reward = FactoryBot.create(:reward, user: @user)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  describe 'GET #index' do
    before do
      FactoryBot.create(:reward, user: @user, valid_till: Date.today + 10.days)
    end

    it 'renders a JSON response with all unexpired and unclaimed rewards' do
      get '/rewards', headers: { 'Authorization' => "Bearer #{@token}" }
      response_body = response.parsed_body
      expect(response.status).to eq(200)
      expect(response_body['success']).to eq(true)
      expect(response_body['message']).to eq(I18n.t('reward.list'))
      expect(response_body['data']['reward']).not_to be_empty
      expect(response_body['data']['reward'][0]['name']).to eq('Coffee Reward')
    end
  end

  describe 'GET #show' do
    context 'when the record exists' do
      it 'renders a JSON response with the reward' do
        get "/rewards/#{@reward.id}", headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq(I18n.t('reward.show'))
        expect(response_body['data']['reward']['id']).to eq(@reward.id)
        expect(response_body['data']['reward']['id']).to eq(@reward.id)
      end
    end

    context 'when the record does not exist' do
      it 'renders a JSON response with a not found message' do
        get '/rewards/0', headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(404)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq('ActiveRecord::RecordNotFound')
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid params' do
      context 'when the reward is not claimed' do
        it 'updates the requested reward' do
          put "/rewards/#{@reward.id}", headers: { 'Authorization' => "Bearer #{@token}" }
          @reward.reload
          response_body = response.parsed_body
          expect(response.status).to eq(200)
          expect(response_body['success']).to eq(true)
          expect(response_body['message']).to eq(I18n.t('reward.update'))
          expect(@reward.claimed_at).not_to be_nil
        end
      end

      context 'when the reward is already claimed' do
        before do
          @reward.update(claimed_at: Time.now, count: 0)
        end

        it 'renders a JSON response with already claimed message' do
          put "/rewards/#{@reward.id}", headers: { 'Authorization' => "Bearer #{@token}" }
          response_body = response.parsed_body
          expect(response.status).to eq(200)
          expect(response_body['success']).to eq(true)
          expect(response_body['message']).to eq(I18n.t('reward.already_claimed'))
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
