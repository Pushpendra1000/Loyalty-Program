# frozen_string_literal: true

# UsersController
class UsersController < ApplicationController
  skip_before_action :authorize_request, only: %i[login create]

  def create
    user = User.new(user_params)

    if user.save
      render_success_response({ user: single_serializer.new(user, serializer: UserSerializer) }, I18n.t('user.create'),
                              201)
    else
      render_unprocessable_entity_response(user)
    end
  end

  def show
    render_success_response({ user: single_serializer.new(@current_user, serializer: UserSerializer) },
                            I18n.t('user.show'))
  end

  def update
    if @current_user.update(user_params)
      render_success_response({ user: single_serializer.new(@current_user, serializer: UserSerializer) },
                              I18n.t('user.update'))
    else
      render_unprocessable_entity_response(@current_user)
    end
  end

  def login
    @user = User.find_by!(email: params[:email])
    if @user.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render_success_response({ token: }, I18n.t('user.login'))
    else
      render_unauthorized_response(I18n.t('user.login_error'))
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :birthday)
  end
end
