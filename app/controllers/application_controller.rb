class ApplicationController < ActionController::Base
  include JsonWebToken
  include ApplicationMethods
  before_action :authorize_request

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = JsonWebToken.decode(header)
    @current_user = User.find(decoded[:user_id]) if decoded
    return render json: { errors: 'Invalid token or token not provided' }, status: :unauthorized unless @current_user
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: 'Unauthorized' }, status: :unauthorized
  end
end
