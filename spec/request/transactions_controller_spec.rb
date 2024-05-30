# frozen_string_literal: true

# spec/requests/transactions_controller_spec.rb
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe TransactionsController, type: :request do
  before(:each) do
    @user = FactoryBot.create(:user)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  let(:valid_attributes) do
    {
      amount: 100,
      currency: 'us'
    }
  end

  let(:invalid_attributes) do
    {
      amount: nil,
      currency: 'us'
    }
  end

  describe 'GET #index' do
    before do
      @transaction = FactoryBot.create(:transaction, user: @user)
    end

    it 'renders a JSON response with all transactions' do
      get '/transactions', headers: { 'Authorization' => "Bearer #{@token}" }
      response_body = response.parsed_body
      expect(response.status).to eq(200)
      expect(response_body['success']).to eq(true)
      expect(response_body['message']).to eq(I18n.t('transaction.list'))
      expect(response_body['data']['transaction']).not_to be_empty
      expect(response_body['data']['transaction'].size).to eq(1)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Transaction' do
        post '/transactions', params: valid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(201)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq(I18n.t('transaction.create'))
        expect(response_body['data']['transaction']['amount']).to eq(100)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new transaction' do
        post '/transactions', params: invalid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(422)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq(I18n.t('transaction.invalid_params'))
      end
    end
  end

  describe 'GET #show' do
    before do
      @transaction = FactoryBot.create(:transaction, user: @user)
    end

    context 'when the record exists' do
      it 'renders a JSON response with the transaction' do
        get "/transactions/#{@transaction.id}", headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq(I18n.t('transaction.show'))
        expect(response_body['data']['transaction']['id']).to eq(@transaction.id)
      end
    end

    context 'when the record does not exist' do
      it 'renders a JSON response with a not found message' do
        get '/transactions/0', headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(404)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq('ActiveRecord::RecordNotFound')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
