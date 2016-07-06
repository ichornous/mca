class ApplicationController < ActionController::Base
  include PunditHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :set_locale!
  before_filter :set_user_info

  # def default_url_options(options = {})
  #   { locale: I18n.locale }.merge options
  # end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  #rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  private
  def set_locale!
    cu_locale = current_user.locale rescue nil
    I18n.locale = cu_locale || I18n.default_locale
  end

  def user_not_authorized
    flash[:alert] = 'Access denied.'
    redirect_to (request.referrer || root_path)
  end

  def set_user_info
    @user_info = {
        id: current_user.try(:id),
        workshop_id: current_user.try(:workshop_id)
    }
  end

  # def record_not_found
  #   render nothing: true, status: :not_found
  # end
end
