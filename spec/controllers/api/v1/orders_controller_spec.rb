require 'rails_helper'

describe Api::V1::OrdersController, type: :controller do
  include Devise::TestHelpers

  def json
    JSON.parse(response.body)
  end

  def booking_as_args(attrs)
    result = {
        description: attrs[:description],
        color: attrs[:color]
    }

    result.merge!(start_date: attrs[:start_date].strftime('%d/%m/%Y')) if attrs[:start_date]
    result.merge!(end_date: attrs[:end_date].strftime('%d/%m/%Y')) if attrs[:end_date]
    result
  end

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
      opts.merge!(start: arg_start.iso8601) if defined?(arg_start)
      opts.merge!(end: arg_end.iso8601) if defined?(arg_end)
      opts.merge!(workshop_id: workshop.id)
      get :index, opts
    end

    let! (:workshop) { create(:workshop) }

    it_has_behavior 'protected from unauthorized access'

    context 'signed in user is authorized to access a resource' do
      let (:user) { create(:sales, workshop: workshop) }

      let! (:past_orders) {
        create_list(:order_in_range, 4, start_date: 4.days.ago, end_date: 1.day.ago, workshop: workshop)
      }
      let! (:future_orders) {
        create_list(:order_in_range, 4, start_date: 1.day.from_now, end_date: 4.days.from_now, workshop: workshop)
      }

      before { sign_in user }

      context 'no range is specified' do
        it_has_behavior 'processes api request with success'

        it 'returns past orders' do
          send_request!

          expect(assigns[:orders]).to include(*past_orders)
        end

        it 'returns future orders' do
          send_request!

          expect(assigns[:orders]).to include(*future_orders)
        end
      end

      context 'date range is specified' do
        let (:arg_start) { 4.days.ago }
        let (:arg_end) { 0.days.from_now }

        it_has_behavior 'processes api request with success'

        it 'returns past orders' do
          send_request!

          expect(assigns[:orders]).to include(*past_orders)
        end

        it 'does not return future orders' do
          send_request!

          expect(assigns[:orders]).to_not include(*future_orders)
        end
      end
    end
  end

  describe 'GET #show' do
    def send_request!(id = nil)
      opts = {}
      opts.merge!(id: id || order.id)
      opts.merge!(workshop_id: workshop.id)
      get :show, opts
    end

    let! (:workshop) { create(:workshop) }
    let! (:order) { create(:order, workshop: workshop) }

    it_has_behavior 'protected from unauthorized access'

    context 'signed in user is authorized to access a resource' do
      let (:user) { create(:sales, workshop: workshop) }
      before { sign_in user }

      it_has_behavior 'processes api request with success'

      it 'returns the requested object' do
        send_request!

        expect(assigns[:order]).to eq(order)
      end

      context 'object does not exist' do
        it 'returns not_found http status' do
          send_request!(113)

          expect(response).to have_http_status(:not_found)
        end

        it 'does not return any content' do
          send_request!(113)

          expect(response.body).to be_blank
        end
      end

    end
  end

  describe 'POST #create' do

    def send_request!
      order = {}
      order.merge!(client: client_attributes) if defined?(client_attributes) and client_attributes
      order.merge!(car: car_attributes) if defined?(car_attributes) and car_attributes

      if defined?(order_attributes) and order_attributes
        order.merge!(start_date: order_attributes[:start_date].strftime('%d/%m/%Y')) if order_attributes[:start_date]
        order.merge!(end_date: order_attributes[:end_date].strftime('%d/%m/%Y')) if order_attributes[:end_date]
        order.merge!(description: order_attributes[:description]) if order_attributes[:description]
        order.merge!(color: order_attributes[:color]) if order_attributes[:color]
      end

      opts = {}
      opts.merge!(order)
      opts.merge!(workshop_id: workshop.id)
      post :create, opts
    end

    let! (:workshop) { create(:workshop) }

    context 'signed in user is authorized to access a resource' do
      let (:user) { create(:sales, workshop: workshop) }
      before { sign_in user }

      let (:order_attributes) { attributes_for(:order) }
      let (:client_attributes) { attributes_for(:client) }
      let (:car_attributes) { attributes_for(:car) }

      shared_context 'creates a new order' do
        it 'adds a new record in the orders table' do
          expect{ send_request! }.to change(Order, :count).by(1)
        end

        it 'returns the id of the newly created order' do
          send_request!

          expect(json['id']).to eq(Order.last.id)
        end

        it 'assigns order attributes to the newly created order' do
          send_request!

          expect(Order.last).to have_attributes(description: order_attributes[:description],
                                                color: order_attributes[:color])
          expect(Order.last).to have_attributes(start_date: be_between(order_attributes[:start_date].beginning_of_day,
                                                                       order_attributes[:start_date].end_of_day)) if order_attributes[:start_date]
          expect(Order.last).to have_attributes(end_date: be_between(order_attributes[:end_date].beginning_of_day,
                                                                     order_attributes[:end_date].end_of_day)) if order_attributes[:end_date]
        end
      end

      shared_context 'associates order with client and car' do
        it 'associates the client with the order' do
          send_request!

          expect(Order.last.client).to eq(Client.last)
        end

        it 'associates the client with the car' do
          send_request!

          expect(Order.last.car).to eq(Car.last)
        end
      end

      shared_context 'does not create an order' do
        it 'does not create an order' do
          expect{ send_request! }.to_not change(Order, :count)
        end
      end

      shared_context 'does not create client, car' do
        it 'does not create a new client' do
          expect{ send_request! }.to_not change(Client, :count)
        end

        it 'does not create a new car' do
          expect{ send_request! }.to_not change(Car, :count)
        end
      end

      shared_context 'reports failure' do
        before do
          send_request!
        end

        it 'has appropriate http status' do
          expect(response).to_not be_success
        end

        it 'returns status :unprocessable_entry' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns a json object with entry `errors`' do
          expect(json).to include('errors')
        end
      end

      context 'valid parameters', focus: true do
        it_has_behavior 'processes api request with success'

        context 'do not reuse a client and an order' do
          it_has_behavior 'creates a new order'
          it_has_behavior 'associates order with client and car'

          it 'creates a new client' do
            expect{ send_request! }.to change(Client, :count).from(0).to(1)
          end

          it 'creates a new car' do
            expect{ send_request! }.to change(Car, :count).from(0).to(1)
          end
        end

        context 'reuse a client and an order' do
          let! (:client) { create(:client, workshop: workshop) }
          let! (:car) { create(:car, workshop: workshop) }

          let (:client_attributes) { client.id }
          let (:car_attributes) { car.id }

          it_has_behavior 'creates a new order'
          it_has_behavior 'associates order with client and car'
          it_has_behavior 'does not create client, car'
        end
      end

      context 'invalid parameters' do
        let! (:client) { create(:client) }
        let! (:car) { create(:car) }

        let (:client_attributes) { client.id }
        let (:car_attributes) { car.id }

        it_has_behavior 'reports failure'
        it_has_behavior 'does not create client, car'
        it_has_behavior 'does not create an order'
      end
    end

    it_has_behavior 'protected from unauthorized access'
  end

  describe 'PUT #update' do
    context 'signed in user is authorized to access a resource'
    context 'signed in user is not authorized to access a resource'
    context 'user is not signed in'
  end
end
