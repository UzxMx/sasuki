class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected
    def authenticate
      token = request.headers['HTTP_X_AUTHORIZATION']
      device = nil
      unless token.empty?
        device = Device.where({ auth_token: token }).first
      end

      if device.nil?
        render json: {}, status: :unauthorized
        return
      end

      @current_device = device
    end
end
