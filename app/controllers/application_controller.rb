class ApplicationController < ActionController::Base
  # rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
  #   render :text => exception, :status => 500
  # end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :set_locale!

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def set_locale!
    cu_locale = current_user.locale rescue nil
    I18n.locale = params[:locale] || cu_locale || I18n.default_locale
  end
end
