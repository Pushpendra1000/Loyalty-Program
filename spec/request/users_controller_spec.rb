# frozen_string_literal: true

# spec/requests/users_controller_spec.rb
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe UsersController, type: :request do
  before(:each) do
    @user = FactoryBot.create(:user)
    @token = JsonWebToken.encode(user_id: @user.id)
  end

  let(:valid_attributes) do
    {
      name: 'John Doe',
      email: 'john.doe@example.com',
      password: 'password',
      password_confirmation: 'password',
      birthday: Date.new(1990, 1, 1)
    }
  end

  let(:invalid_attributes) do
    {
      name: '',
      email: 'john.doe@example.com',
      password: 'pass',
      password_confirmation: 'pass',
      birthday: Date.new(1990, 1, 1)
    }
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        post '/users', params: valid_attributes
        response_body = response.parsed_body
        expect(response.status).to eq(201)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq(I18n.t('user.create'))
        expect(response_body['data']['user']['name']).to eq('John Doe')
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new user' do
        post '/users', params: invalid_attributes
        response_body = response.parsed_body
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq(I18n.t('user.invalid_params'))
      end
    end
  end

  describe 'GET #show' do
    before do
      @user = FactoryBot.create(:user)
      @token = JsonWebToken.encode(user_id: @user.id)
    end

    it 'renders a JSON response with the user' do
      get "/users/#{@user.id}", headers: { 'Authorization' => "Bearer #{@token}" }
      response_body = response.parsed_body
      expect(response.status).to eq(200)
      expect(response_body['success']).to eq(true)
      expect(response_body['message']).to eq(I18n.t('user.show'))
      expect(response_body['data']['user']['name']).to eq(@user.name)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid params' do
      it 'updates the requested user' do
        put "/users/#{@user.id}", params: valid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        @user.reload
        response_body = response.parsed_body
        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq(I18n.t('user.update'))
        expect(response_body['data']['user']['name']).to eq(@user.name)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the user' do
        put "/users/#{@user.id}", params: invalid_attributes, headers: { 'Authorization' => "Bearer #{@token}" }
        response_body = response.parsed_body
        expect(response.status).to eq(422)
        expect(response_body['success']).to eq(false)
        expect(response_body['message']).to eq(I18n.t('user.invalid_params'))
        expect(response_body['errors'][0]['detail']).to eq("can't be blank")
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'POST #login' do
    context 'with valid credentials' do
      it 'authenticates the user and returns a token' do
        post '/users/login', params: { email: @user.email, password: @user.password }
        response_body = response.parsed_body
        expect(response.status).to eq(200)
        expect(response_body['success']).to eq(true)
        expect(response_body['message']).to eq(I18n.t('user.login'))
      end
    end

    context 'with invalid credentials' do
      it 'renders a JSON response with an error message' do
        post '/users/login', params: { email: @user.email, password: 'wrong_password' }
        response_body = response.parsed_body
        expect(response.status).to eq(401)
        expect(response_body['success']).to eq(false)
        expect(response_body['errors'][0]).to eq(I18n.t('user.login_error'))
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
