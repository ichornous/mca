require 'rails_helper'

describe VisitsController, type: :controller do
  include Devise::TestHelpers

  describe 'GET #index' do
    #
    # WEB Page request
    #
    context 'web page is requested' do
      context 'user is logged in' do
        with_user :user
        before { get :index }

        it { is_expected.to respond_with :ok}
        it { is_expected.to render_with_layout :application }
        it { is_expected.to render_template :index }

        it { is_expected.to assign_to(:workshop).with(user.workshop) }
        it { is_expected.to_not assign_to(:visits) }
        it { is_expected.to assign_to(:cursor_date) }
      end

      context 'disguised user is logged in' do
        let (:workshop_1) { create(:workshop) }
        let (:workshop_2) { create(:workshop) }
        let (:disguised_user) { create(:user, workshop: workshop_1, impersonation: workshop_2) }
        before {
          sign_in disguised_user
          get :index
        }

        it { is_expected.to respond_with :ok}
        it { is_expected.to render_with_layout :application }
        it { is_expected.to render_template :index }

        it { is_expected.to assign_to(:workshop).with(disguised_user.impersonation) }
        it { is_expected.to_not assign_to(:visits) }
        it { is_expected.to assign_to(:cursor_date) }
      end

      context 'user is not logged in' do
        before { get :index }

        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    #
    # Event API request
    #
    context 'range of events is queried' do
      let (:workshop_1) { create(:workshop) }
      let (:evt_in_range) { create(:visit, :started_4days_from_now, workshop: workshop_1) }
      let (:evt_out_of_range) { create(:visit, :started_4days_ago, workshop: workshop_1) }

      let (:workshop_2) { create(:workshop) }
      let (:evt_in_range_diff) { create(:visit, :started_4days_from_now, workshop: workshop_2) }
      let (:evt_out_of_range_diff) { create(:visit, :started_4days_ago, workshop: workshop_2) }

      let (:user) { create(:user, workshop: workshop_1) }
      let (:disguised_user) { create(:user, workshop: workshop_1, impersonation: workshop_2) }

      let (:range_start) { 4.days.from_now }
      let (:end_start) { 8.days.from_now }

      def run_query!
        get :index, format: :json, start: range_start.strftime('%d/%m/%Y'), end: end_start.strftime('%d/%m/%Y')
      end

      context 'valid parameters' do
        before {
          evt_in_range
          evt_out_of_range
          evt_in_range_diff
          evt_out_of_range_diff
        }

        it 'returns range of visits for the user workshop' do
          sign_in user
          run_query!
          expect(assigns(:visits)).to eq([evt_in_range])
        end

        it 'returns range of visits for the user impersonation workshop' do
          sign_in disguised_user
          run_query!
          expect(assigns(:visits)).to eq([evt_in_range_diff])
        end

        it 'redirects the user to the new session controller if he is not logged in' do
          run_query!
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
