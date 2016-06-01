module Api
  module V1
    class ApiController < ActionController::Base
      include PunditHelper

      after_action :verify_authorized
      before_filter :user_needed

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private
      def user_needed
        render nothing: true, status: :unauthorized unless current_user
      end

      def user_not_authorized
        render nothing: true, status: :unauthorized
      end
    end
  end
end
