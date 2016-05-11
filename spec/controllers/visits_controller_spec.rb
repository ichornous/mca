require 'rails_helper'

describe VisitsController, type: :controller do
  include Devise::TestHelpers

  describe 'GET #index' do
    context 'user is logged in' do
      with_user :user
      before { get :index }

      it { is_expected.to respond_with :ok}
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :index }

      it { is_expected.to assign_to(:workshop).with(user.workshop) }
    end

    context 'disguised user is logged in' do
      with_user :user, :in_disguise
      before { get :index }

      it { is_expected.to respond_with :ok}
      it { is_expected.to render_with_layout :application }
      it { is_expected.to render_template :index }

      it { is_expected.to assign_to(:workshop).with(user.impersonation) }
    end

    context 'user is logged out' do
      before { get :index }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end
end
