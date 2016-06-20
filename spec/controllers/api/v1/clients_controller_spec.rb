require 'rails_helper'

describe Api::V1::ClientsController, type: :controller do
  include Devise::TestHelpers

  shared_context 'processes api request with success' do
    it 'does not render a layout' do
      send_request!

      is_expected.to_not render_with_layout :application
    end

    it 'is successful' do
      send_request!

      expect(response).to have_http_status(:success)
    end

    it 'responds with json' do
      send_request!

      expect(response.header['Content-Type']).to include 'application/json'
    end
  end

  shared_context 'protected from unauthorized access' do
    shared_context 'prohibits unauthorized access' do
      it 'fails with unauthorized http status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not return content' do
        expect(response.body).to be_blank
      end
    end

    context 'signed in user is not authorized to access a resource' do
      let (:user) { create(:sales) }

      before do
        sign_in user
        send_request!
      end

      it_has_behavior 'prohibits unauthorized access'
    end

    context 'user is not signed in' do
      before { send_request! }

      it_has_behavior 'prohibits unauthorized access'
    end
  end

  describe 'GET #index' do
    def send_request!
      opts = {}
      opts.merge!(limit: limit) if defined?(limit)
      opts.merge!(page: page) if defined?(page)
      opts.merge!(page_size: page_size) if defined?(page_size)
      opts.merge!(query: query) if defined?(query)
      opts.merge!(workshop_id: workshop.id)
      opts.merge!(format: :json)
      get :index, opts
    end

    let! (:workshop) { create(:workshop) }
    let! (:clients) { create_list(:client, 10, workshop: workshop) }

    it_has_behavior 'protected from unauthorized access'

    context 'signed in user is authorized to access a resource' do
      let (:user) { create(:sales, workshop: workshop) }

      before { sign_in user }

      context 'no query is given' do
        it_has_behavior 'processes api request with success'

        it 'returns clients' do
          send_request!

          expect(assigns[:clients]).to include(*clients)
        end
      end

      context 'limit is provided' do
        let (:limit) { 3 }

        it_has_behavior 'processes api request with success'

        it 'returns clients' do
          send_request!

          expect(clients).to include(*assigns[:clients])
        end

        it 'returns no more then `limit` # of clients' do
          send_request!

          expect(assigns[:clients].size).to eq(limit)
        end
      end

      context 'limit and page_max are provided' do
        let (:limit) { 20 }
        let (:page_size) { 3 }
        it_has_behavior 'processes api request with success'

        it 'returns clients' do
          send_request!

          expect(clients).to include(*assigns[:clients])
        end

        it 'returns no more then `page_max` # of clients' do
          send_request!

          expect(assigns[:clients].size).to eq(page_size)
        end
      end


    end
  end

end
