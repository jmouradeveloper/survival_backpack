module Authorization
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    rescue_from Authorization::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def authorize_admin!
    unless current_user&.admin?
      raise Authorization::NotAuthorizedError, "You are not authorized to perform this action."
    end
  end

  def authorize_owner!(resource)
    unless current_user&.admin? || resource.user_id == current_user&.id
      raise Authorization::NotAuthorizedError, "You are not authorized to access this resource."
    end
  end

  def user_not_authorized(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end
end

