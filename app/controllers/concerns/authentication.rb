module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    before_action :check_session_expiration
    helper_method :current_user, :user_signed_in?
  end

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: "You must be signed in to access this page."
    end
  end

  def current_user
    Current.user
  end

  def user_signed_in?
    current_user.present?
  end

  def set_current_user
    if session[:user_id].present?
      Current.user = User.find_by(id: session[:user_id])
      
      # Clear session if user not found
      reset_session if Current.user.nil?
    end
  end

  def check_session_expiration
    if user_signed_in? && current_user.session_expired?
      reset_session
      Current.user = nil
      redirect_to login_path, alert: "Your session has expired. Please sign in again."
    end
  end

  def login(user)
    reset_session
    session[:user_id] = user.id
    Current.user = user
    user.update_last_login!
  end

  def logout
    reset_session
    Current.user = nil
  end
end

