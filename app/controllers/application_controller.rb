class ApplicationController < ActionController::Base
  include PunditHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :set_locale!

  # def default_url_options(options = {})
  #   { locale: I18n.locale }.merge options
  # end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private
  def set_locale!
    cu_locale = current_user.locale rescue nil
    I18n.locale = cu_locale || I18n.default_locale
  end

  def user_not_authorized
    flash[:alert] = 'Access denied.'
    redirect_to (request.referrer || root_path)
  end
end
