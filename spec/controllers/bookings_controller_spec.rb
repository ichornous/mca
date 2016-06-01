require 'rails_helper'

describe BookingsController, type: :controller do
  include Devise::TestHelpers

  describe 'GET #index' do
    #
    # Helpers
    #
    def send_request!
      opts = {}
      opts.merge!(day: arg_today_s) if defined?(arg_today_s)
      opts.merge!(start: arg_start.iso8601) if defined?(arg_start)
      opts.merge!(end: arg_end.iso8601) if defined?(arg_end)
      opts.merge!(format: arg_format) if defined?(arg_format)
      get :index, opts
    end

    shared_context 'it returns a form' do
      it { is_expected.to render_with_layout :application }
      it { expect(response.header['Content-Type']).to include 'html' }
    end

    shared_context 'it returns a json block' do
      let (:arg_format) { :json }

      it { is_expected.to_not render_with_layout :application }
      it { expect(response.header['Content-Type']).to include 'json' }
    end

    shared_context 'it succeeds' do
      before { send_request! }

      it_has_behavior 'it returns a form'
      it_has_behavior 'it returns a json block'

      it { is_expected.to respond_with :ok}
      it { is_expected.to render_template :index }

      it { is_expected.to assign_to(:bookings) }
      it { is_expected.to assign_to(:cursor_date) }
      it { is_expected.to assign_to(:workshop).with(user.current_workshop) }
    end

    #
    # Behaviors
    #
    shared_context 'handles cursor date' do
      include_context 'it succeeds'

      context 'when cursor date is given' do
        let(:arg_today_s) { 2.days.ago.strftime('%Y-%m-%d') }

        it { expect(assigns[:cursor_date]).to eq(arg_today_s) }
      end

      context 'when cursor date is not given' do
        it { expect(assigns[:cursor_date]).to eq(DateTime.now.strftime('%Y-%m-%d')) }
      end
    end

    shared_context 'handles date range' do
      include_context 'it succeeds'

      let (:smallest_date) { 10.years.ago }
      let (:largest_date) { 10.years.from_now }

      before do
        21.times { |n| create(:booking, start_date: n.days.from_now - 2.weeks) }
        21.times { |n| create(:booking, start_date: n.days.from_now - 2.weeks, workshop: user.current_workshop) }
      end

      context 'when date range is not given' do
        it { expect(assigns[:bookings]).to be_empty }
      end

      context 'when only start date is given' do
        let (:arg_start) { 1.day.ago }

        it { expect(assigns[:bookings]).to be_empty }
      end

      context 'when only end date is given' do
        let (:arg_end) { 1.day.ago }

        it { expect(assigns[:bookings]).to be_empty }
      end

      context 'when full range is given' do
        let (:arg_start) { 7.days.ago }
        let (:arg_end) { 7.days.from_now }
        let (:subject) { assigns[:bookings] }

        it 'returns only visits for the user`s current workshop' do
          is_expected.to include(have_attributes(workshop_id: user.current_workshop.id))
        end

        it 'does not return visits for other workshops' do
          is_expected.to_not include(not_have_attributes(workshop_id: user.current_workshop.id))
        end

        it 'returns visits from a given date range' do
          is_expected.to match_array(Booking.range(user.current_workshop, arg_start, arg_end))
        end

        it 'does not return visits which ended before the beginning of a given range' do
          is_expected.to_not include(have_attributes(end_date: a_value_between(smallest_date, arg_start)))
        end

        it 'does not return visits which started after the end of a given range' do
          is_expected.to_not include(have_attributes(start_date: a_value_between(arg_end, largest_date)))
        end
      end
    end

    shared_context 'handles impersonation' do
      include_context 'it succeeds'

      context 'when full range is given' do
        before do
          21.times { |n| create(:booking, start_date: n.days.from_now - 2.weeks, workshop: user.workshop) }
          21.times { |n| create(:booking, start_date: n.days.from_now - 2.weeks, workshop: user.impersonation) }
        end

        let (:arg_start) { 7.days.ago }
        let (:arg_end) { 7.days.from_now }
        let (:subject) { assigns[:bookings] }

        it 'returns visits from the impersonated workshop' do
          is_expected.to match_array(Booking.range(user.impersonation, arg_start, arg_end))
        end
      end
    end

    #
    # Conditions
    #
    context 'user is signed in' do
      before { sign_in user }

      context 'user is in role sales' do
        let(:user) { create(:sales) }

        it_has_behavior 'handles cursor date'
        it_has_behavior 'handles date range'
      end

      context 'user is in role manager' do
        let(:user) { create(:manager) }

        it_has_behavior 'handles cursor date'
        it_has_behavior 'handles date range'
      end

      context 'user is in role admin' do
        let(:user) { create(:admin) }

        it_has_behavior 'handles cursor date'
        it_has_behavior 'handles date range'
      end

      context 'user is disguised' do
        let(:workshop) { create(:workshop) }
        let(:user) {
          admin = create(:admin)
          admin.impersonate(workshop)
          admin.save
          admin
        }

        it_has_behavior 'handles cursor date'
        it_has_behavior 'handles date range'
        it_has_behavior 'handles impersonation'
      end
    end

    context 'user is not signed in' do
      before { get :index }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  describe 'GET #show' do
    let (:foreign_visit) { create(:booking) }
    let (:relevant_visit) { create(:booking, workshop: user.workshop) }

    context 'user is signed in' do
      before { sign_in user }

      context 'user is in role `sales`' do
        let (:user) { create(:sales) }

        it 'can see a visit from the same workshop' do
          get :show, id: relevant_visit.id

          expect(response).to be_success
        end

        it 'can not see a visit from a different workshop' do
          get :show, id: foreign_visit.id

          expect(response).to have_http_status(404)
        end
      end

      context 'user is in role `manager`' do
        let (:user) { create(:manager) }

        it 'can see a visit from the same workshop' do
          get :show, id: relevant_visit.id

          expect(response).to be_success
        end

        it 'can not see a visit from a different workshop' do
          get :show, id: foreign_visit.id

          expect(response).to have_http_status(404)
        end
      end

      context 'user is in role `admin`' do
        let (:user) { create(:admin) }

        it 'can see a visit from the same workshop' do
          get :show, id: relevant_visit.id

          expect(response).to be_success
        end

        it 'can not see a visit from a different workshop' do
          get :show, id: foreign_visit.id

          expect(response).to have_http_status(404)
        end
      end

      context 'user is disguised' do
        let (:workshop) { create(:workshop) }
        let (:user) {
          admin = create(:admin)
          admin.impersonate(workshop)
          admin.save
          admin
        }
        let (:impersonated_visit) { create(:booking, workshop: workshop) }

        it 'can see a visit from the current workshop' do
          get :show, id: impersonated_visit.id

          expect(response).to be_success
        end

        it 'can not see a visit from the private workshop' do
          get :show, id: relevant_visit.id

          expect(response).to have_http_status(404)
        end

        it 'can not see a visit from a different workshop' do
          get :show, id: foreign_visit.id

          expect(response).to have_http_status(404)
        end
      end
    end

    context 'user is not signed in' do
      it 'can not see a visit' do
        get :show, id: foreign_visit.id

        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'GET #new' do
    #
    # Helpers
    #
    def send_request!
      opts = {}
      opts.merge!(at: arg_today.strftime('%Y-%m-%d')) if defined?(arg_today)

      get :new, opts
    end

    context 'user is signed in' do
      before do
        Timecop.freeze

        sign_in user
        send_request!
      end

      after do
        Timecop.return
      end

      shared_context 'assigns a new visit' do
        let (:subject) { assigns[:booking] }

        it { is_expected.to_not be_nil }
        it 'returns a new visit' do
          is_expected.to be_a(Booking)
        end

        it 'assigns the user`s current workshop to a new visit' do
          expect(subject.workshop).to eq(user.current_workshop)
        end

        it 'assigns the user`s current workshop to a new order' do
          expect(subject.order.workshop).to eq(user.current_workshop)
        end

        context 'date is given as an argument' do
          let (:arg_today) { 7.days.from_now.to_datetime }

          it 'start_date should be within the same date as requested' do
            expect(subject.start_date).to be_within_same_day(arg_today)
          end

          it 'end_date should be within the same date as requested' do
            expect(subject.end_date).to be_within_same_day(arg_today)
          end
        end

        context 'date argument is omitted' do
          it 'start_date should be within the current day' do
            expect(subject.start_date).to be_within_same_day(DateTime.now)
          end

          it 'end_date should be within the current day' do
            expect(subject.end_date).to be_within_same_day(DateTime.now)
          end
        end
      end

      context 'user is in role sales' do
        let (:user) { create(:sales) }

        it_has_behavior 'assigns a new visit'
      end

      context 'user is in role manager' do
        let (:user) { create(:manager) }

        it_has_behavior 'assigns a new visit'
      end

      context 'user is in role admin' do
        let (:user) { create(:admin) }

        it_has_behavior 'assigns a new visit'
      end

      context 'user is disguised' do
        let (:workshop) { create(:workshop) }
        let (:user) {
          admin = create(:admin)
          admin.impersonate(workshop)
          admin.save
          admin
        }

        it_has_behavior 'assigns a new visit'
      end
    end

    context 'user is not signed in' do
      before do
        send_request!
      end

      it 'can not see a visit' do
        is_expected.to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #create' do
    def send_request!
      visit.merge!(order_attributes: order_attributes) if defined?(order_attributes)
      visit.merge!(workshop_id: supplied_workshop_id) if defined?(supplied_workshop_id)

      post :create, booking: visit
    end

    shared_context 'creates a new visit' do
      it 'should create a new visit with associated services' do
        expect {
          send_request!
        }.to change(Booking, :count).by(1)
      end

      it 'redirects to the visit`s date in the calendar' do
        send_request!

        expect(response).to redirect_to visits_path(day: Booking.last.start_date.strftime('%Y-%m-%d'))
      end

      it 'should assign the current user`s workshop id' do
        send_request!

        expect(Booking.last.workshop_id).to eq(current_workshop.id)
      end

      it 'should create an associated order' do
        send_request!

        expect(Booking.last.order).to_not be_nil
      end

      it 'should assign the current user`s workshop id to the corresponding order' do
        send_request!

        expect(Booking.last.order.workshop_id).to eq(current_workshop.id)
      end

      it 'does not create a new service' do
        expect { send_request! }.to_not change(Service, :count)
      end
    end

    shared_context 'does not create a visit' do
      it 'does not create a new visit' do
        expect { send_request! }.to_not change(Booking, :count)
      end

      it 'does not create a new order service' do
        expect { send_request! }.to_not change(OrderService, :count)
      end

      it 'does not create a new service' do
        expect { send_request! }.to_not change(Service, :count)
      end

      it 'does not create a new service before the request is made' do
        expect(Service.count).to eq(0)
      end

      it 'renders the `new visit` page' do
        send_request!

        expect(response).to render_template :new
      end
    end

    shared_context 'handle nested services' do
      let (:current_workshop) { user.current_workshop }
      let (:supplied_workshop_id) { current_workshop.id }
      let (:booking) { attributes_for(:booking) }

      context 'order attributes are not given' do
        let (:order_attributes) { nil }

        it_has_behavior 'creates a new visit'
      end

      context 'order attributes are empty' do
        let (:order_attributes) { {} }

        it_has_behavior 'creates a new visit'
      end

      context 'services are specified' do
        let! (:services) { create_list(:service, 3) }
        let (:orders) {
          services.map {|s| attributes_for(:order_service).merge(workshop_id: current_workshop.id, service_id: s.id) }
        }
        let (:order_attributes) {
          {
              order_services_attributes: {
                  '1': orders[0],
                  '2': orders[1],
                  '3': orders[2]
              }
          }
        }

        it_has_behavior 'creates a new visit'

        it 'establishes association between order and services' do
          send_request!

          expect(Booking.last.order.services).to match_array(services)
        end

        it 'creates corresponding OrderService records' do
          expect { send_request! }.to change(OrderService, :count).by(3)
        end
      end

      context 'services are not specified' do
        let (:order_attributes) {
          { order_services_attributes: {} }
        }

        it_has_behavior 'creates a new visit'

        it 'does not create a new order service' do
          expect { send_request! }.to_not change(OrderService, :count)
        end
      end

      context 'invalid service is specified' do
        let (:orders) { attributes_for(:order_service).merge(service_id: 1) }
        let (:order_attributes) {
          { order_services_attributes: {'1': order} }
        }

        it_has_behavior 'does not create a visit'
      end
    end

    shared_context 'ignores supplied workshop id' do
      let (:current_workshop) { user.current_workshop }
      let (:booking) { attributes_for(:booking) }
      let (:order_attributes) { {} }

      context 'alternative workshop exists' do
        let (:alt_workshop) { create(:workshop)}
        let (:supplied_workshop_id) { alt_workshop.id }

        it_has_behavior 'creates a new visit'
      end

      context 'alternative workshop does not exist' do
        let (:supplied_workshop_id) { 4 }

        it_has_behavior 'creates a new visit'
      end
    end

    shared_context 'override workshop id' do
      let (:booking) { attributes_for(:booking) }
      let (:order_attributes) { {} }

      context 'alternative workshop exists' do
        let (:current_workshop) { create(:workshop) }
        let (:supplied_workshop_id) { current_workshop.id }

        it_has_behavior 'creates a new visit'
      end

      context 'alternative workshop exists' do
        let (:supplied_workshop_id) { 4 }

        it_has_behavior 'does not create a visit'
      end
    end

    context 'user is signed in' do
      before do
        sign_in user
      end

      context 'user is in role sales' do
        let (:user) { create(:sales) }

        it_has_behavior 'handle nested services'
        it_has_behavior 'ignores supplied workshop id'
      end

      context 'user is in role manager' do
        let (:user) { create(:manager) }

        it_has_behavior 'handle nested services'
        it_has_behavior 'ignores supplied workshop id'
      end

      context 'user is in role admin' do
        let (:user) { create(:admin) }

        it_has_behavior 'handle nested services'
        it_has_behavior 'override workshop id'
      end

      context 'user is disguised' do
        let (:workshop) { create(:workshop) }
        let (:user) {
          admin = create(:admin)
          admin.impersonate(workshop)
          admin.save
          admin
        }

        it_has_behavior 'handle nested services'
        it_has_behavior 'override workshop id'
      end
    end

    context 'user is not signed in' do
      let (:booking) { attributes_for(:booking) }

      before { send_request! }

      it 'redirects to the new session page' do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PUT #update' do
    def send_request!
      visit_attrs.merge!(order_attributes: order_attributes) if defined?(order_attributes)
      visit_attrs.merge!(workshop_id: alter_workshop_id) if defined?(alter_workshop_id) and alter_workshop_id != visit.workshop.id
      put :update, id: visit.id, booking: visit_attrs
    end

    def query_visit
      Booking.find(visit.id)
    end

    let (:booking) { create(:visit_with_order, workshop: user.current_workshop) }
    let (:visit_attrs) { attributes_for(:booking) }

    before { booking }

    shared_context 'updates a visit' do
      it 'should not create a new visit' do
        expect {
          send_request!
        }.to change(Booking, :count).by(0)
      end

      it 'redirects to the visit`s date in the calendar' do
        send_request!

        expect(response).to redirect_to visits_path(day: Booking.last.start_date.strftime('%Y-%m-%d'))
      end

      it 'should assign the current user`s workshop id' do
        send_request!

        expect(Booking.last.workshop_id).to eq(current_workshop.id)
      end

      it 'should create an associated order' do
        send_request!

        expect(Booking.last.order).to_not be_nil
      end

      it 'should assign the current user`s workshop id to the corresponding order' do
        send_request!

        expect(Booking.last.order.workshop_id).to eq(current_workshop.id)
      end

      it 'does not create new services' do
        expect{ send_request! }.to_not change(Service, :count)
      end

      it 'does not create new orders' do
        expect{ send_request! }.to_not change(Order, :count)
      end

      it 'does not change the order' do
        expect{ send_request! }.to_not change{ query_visit.order }
      end
    end

    shared_context 'does not change the order' do
      it 'removes items from the order' do
        expect{send_request!}.to_not change{ query_visit.order.order_services }
      end

      it 'does not remove order items' do
        send_request!

        expect(OrderService.exists?(id: booking.order.order_services[0].id)).to be_truthy
        expect(OrderService.exists?(id: booking.order.order_services[1].id)).to be_truthy
        expect(OrderService.exists?(id: booking.order.order_services[2].id)).to be_truthy
      end

      it 'does not remove services' do
        send_request!

        expect(Service.exists?(id: booking.order.order_services[0].service.id)).to be_truthy
        expect(Service.exists?(id: booking.order.order_services[1].service.id)).to be_truthy
        expect(Service.exists?(id: booking.order.order_services[2].service.id)).to be_truthy
      end
    end

    shared_context 'reports validation errors' do
      before { send_request! }

      it 'renders the :show page' do
        is_expected.to render_template :show
      end

      it 'provides validation errors' do
        expect(assigns[:booking].errors.any?).to be_truthy
      end
    end

    shared_context 'handle visit update' do
      let (:current_workshop) { user.current_workshop }

      context 'valid data provided with no order' do
        it_has_behavior 'updates a visit'
        it_has_behavior 'does not change the order'
      end

      context 'valid data provided with an empty order' do
        let (:order_attributes) { {} }

        it_has_behavior 'updates a visit'
        it_has_behavior 'does not change the order'
      end

      context 'valid data provided with a destroy flag on an order item' do
        let (:order_attributes) { { order_services_attributes: order_service_attributes } }
        let (:order_service_attributes) {
          {'1' => {id: booking.order.order_services[2].id, _destroy: '1' }}
        }

        it_has_behavior 'updates a visit'

        it 'removes the item from the order' do
          send_request!

          expect(Order.find(booking.order.id).order_services).to contain_exactly(booking.order.order_services[0],
                                                                                 booking.order.order_services[1])
        end

        it 'removes the item from the database' do
          send_request!

          expect(OrderService.exists?(booking.order.order_services[2].id)).to be_falsey
        end
      end

      context 'valid data with new items' do
        let (:order_attributes) { { order_services_attributes: order_service_attributes } }
        let (:order_service_attributes) {
          {'1' => { service_id: Service.first.id }}
        }

        it_has_behavior 'updates a visit'

        it 'creates a new order item' do
          expect{ send_request! }.to change(OrderService, :count).by(1)
        end

        it 'adds a new order item to the order' do
          expect{ send_request! }.to change{ query_visit.order.order_services.count }.by(1)
        end
      end

      context 'destroy flag is set on a foreign item order' do
        # Deliberate attempt to corrupt data
        let (:order_attributes) { { order_services_attributes: order_service_attributes } }
        let! (:foreight_visit) { create(:visit_with_order) }
        let (:order_service_attributes) {
          {'1' => { id: foreight_visit.order.order_services[2].id, _destroy: '1' }}
        }

        it_has_behavior 'does not change the order'

        it 'returns `not found`' do
          send_request!

          expect(response).to have_http_status(404)
        end

        it 'does not remove the referenced order item' do
          send_request!

          expect(OrderService.exists?(foreight_visit.order.order_services[2].id)).to be_truthy
        end

        it 'does not change the foreign order' do
          expect{ send_request! }.to_not change{ Order.find(foreight_visit.order.id).order_services }
        end

        it 'does not change the number of order services' do
          expect{ send_request! }.to_not change(OrderService, :count)
        end
      end

      context 'invalid data in visit fields' do
        let (:visit_attrs) { attributes_for(:booking_invalid_fields) }

        it_has_behavior 'does not change the order'
        it_has_behavior 'reports validation errors'
      end
    end

    shared_context 'ignores supplied workshop id' do
      let (:current_workshop) { user.current_workshop }
      let (:alter_workshop_id) { create(:workshop).id }

      it_has_behavior 'handle visit update'

      it 'does not change the visit`s workshop' do
        expect{ send_request! }.to_not change{query_visit.workshop}
      end
    end

    shared_context 'override workshop id' do
      let (:current_workshop) { create(:workshop) }
      let (:alter_workshop_id) { current_workshop.id }

      it_has_behavior 'handle visit update'

      it 'changes the visit`s workshop' do
        expect{ send_request! }.to change{query_visit.workshop}.from(user.current_workshop).to(current_workshop)
      end
    end

    context 'user is signed in' do
      before do
        sign_in user
      end

      context 'user is in role sales' do
        let (:user) { create(:sales) }

        it_has_behavior 'handle visit update'
        it_has_behavior 'ignores supplied workshop id'
      end

      context 'user is in role manager' do
        let (:user) { create(:manager) }

        it_has_behavior 'handle visit update'
        it_has_behavior 'ignores supplied workshop id'
      end

      context 'user is in role admin' do
        let (:user) { create(:admin) }

        it_has_behavior 'handle visit update'
        it_has_behavior 'override workshop id'
      end

      context 'user is disguised' do
        let (:workshop) { create(:workshop) }
        let (:user) {
          admin = create(:admin)
          admin.impersonate(workshop)
          admin.save
          admin
        }

        it_has_behavior 'handle visit update'
        it_has_behavior 'override workshop id'
      end
    end

    context 'user is not signed in' do
      let (:booking) { create(:visit_with_order, workshop: create(:workshop)) }

      it 'redirects to the new session page' do
        send_request!

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'DELETE #delete' do
    def send_request!
      delete :destroy, id: visit.id
    end

    def query_visit
      Booking.find(visit.id)
    end

    let (:booking) { create(:visit_with_order, workshop: workshop) }

    before { booking }

    shared_context 'cancel a visit' do
      it 'redirects to the :index page' do
        send_request!

        expect(response).to redirect_to visits_path
      end

      it 'removes a visit' do
        expect{ send_request! }.to change(Booking, :count).by(-1)
      end

      it 'removes the visit' do
        send_request!

        expect(Booking.exists?(booking.id)).to be_falsey
      end

      it 'removes an order' do
        expect{ send_request! }.to change(Order, :count).by(-1)
      end

      it 'removes the associated order' do
        send_request!

        expect(Order.exists?(booking.order.id)).to be_falsey
      end

      it 'remove order items' do
        expect{ send_request! }.to change(OrderService, :count).by(-3)
      end

      it 'remove the order items' do
        ids = [booking.order.order_services[0].id,
               booking.order.order_services[1].id,
               booking.order.order_services[2].id]

        send_request!

        expect(OrderService.exists?(id: ids)).to be_falsey

      end

      it 'does not remove services' do
        expect{ send_request! }.to_not change(Service, :count)
      end
    end

    shared_context 'cannot cancel a visit' do
      it 'returns :notfound result' do
        send_request!

        expect(response).to have_http_status(404)
      end

      it 'does not remove a visit' do
        expect{ send_request! }.to_not change(Booking, :count)
      end

      it 'does not remove the visit' do
        send_request!

        expect(Booking.exists?(booking.id)).to be_truthy
      end

      it 'does not remove an order' do
        expect{ send_request! }.to_not change(Order, :count)
      end

      it 'does not remove the associated order' do
        send_request!

        expect(Order.exists?(booking.order.id)).to be_truthy
      end

      it 'does not remove order items' do
        expect{ send_request! }.to_not change(OrderService, :count)
      end

      it 'does not remove the order items' do
        ids = [booking.order.order_services[0].id,
               booking.order.order_services[1].id,
               booking.order.order_services[2].id]

        send_request!

        expect(OrderService.exists?(id: ids[0])).to be_truthy
        expect(OrderService.exists?(id: ids[1])).to be_truthy
        expect(OrderService.exists?(id: ids[2])).to be_truthy
      end

      it 'does not remove services' do
        expect{ send_request! }.to_not change(Service, :count)
      end
    end

    shared_context 'handles visit cancellation' do
      context 'current workshop' do
        let (:workshop) { user.current_workshop }

        it_has_behavior 'cancel a visit'
      end


      context 'foreign workshop' do
        let (:workshop) { create(:workshop) }

        it_has_behavior 'cannot cancel a visit'
      end
    end

    context 'user is signed in' do
      before do
        sign_in user
      end

      context 'user is in role sales' do
        let (:user) { create(:sales) }

        it_has_behavior 'handles visit cancellation'
      end

      context 'user is in role manager' do
        let (:user) { create(:manager) }

        it_has_behavior 'handles visit cancellation'
      end

      context 'user is in role admin' do
        let (:user) { create(:admin) }

        it_has_behavior 'handles visit cancellation'
      end

      context 'user is disguised' do
        let (:alt_workshop) { create(:workshop) }
        let (:user) {
          admin = create(:admin)
          admin.impersonate(alt_workshop)
          admin.save
          admin
        }

        it_has_behavior 'handles visit cancellation'

        context 'personal workshop' do
          let (:workshop) { user.workshop }

          it_has_behavior 'cannot cancel a visit'
        end
      end
    end

    context 'user is not signed in' do
      let (:workshop) { create(:workshop) }

      it 'redirects to the new session page' do
        send_request!

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
