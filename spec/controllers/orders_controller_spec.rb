
describe OrdersController do
  include Devise::TestHelpers

  def to_slashes(date)
    date.strftime('%d/%m/%Y')
  end

  def to_dashes(date)
    date.strftime('%Y-%m-%d')
  end

  shared_context 'forbids unauthenticated access' do
    before { send_request! }

    let!(:user) { nil }
    it { is_expected.to redirect_to new_user_session_path }
  end

  describe '#index' do
    def send_request!
      sign_in user if defined?(user) and not user.nil?

      opts = {}
      opts.merge!(day: current_day) if defined?(current_day) and not current_day.nil?
      get :index, opts
    end

    let! (:user) { create(:sales) }

    context 'default screen' do
      before { send_request! }

      it 'succeeds' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns the current date' do
        expect(assigns(:cursor_date)).to be_within_same_day(DateTime.now)
      end

      it 'assigns the user current workshop' do
        expect(assigns(:workshop)).to eq(user.workshop)
      end
    end

    context 'day supplied' do
      before {
        send_request!
      }

      let! (:current_day) { 2.days.from_now.strftime('%Y-%m-%d') }

      it 'assigns the current date' do
        expect(assigns(:cursor_date)).to be_within_same_day(2.days.from_now)
      end
    end

    context 'invalid day supplied' do
      before { send_request! }

      let! (:current_day) { 'WOW! SUCH DOGE!' }

      it 'assigns the current date' do
        expect(assigns(:cursor_date)).to be_within_same_day(DateTime.now)
      end
    end

    it_has_behavior 'forbids unauthenticated access'
  end

  describe '#show' do
    def send_request!
      sign_in user if defined?(user) and not user.nil?

      opts = {}
      opts.merge!(id: order_id)
      get :show, opts
    end

    let (:workshop) { create(:workshop) }
    let! (:user) { create(:sales, workshop: workshop) }

    let (:order_id) { 0 }

    context 'the order exists' do
      before { send_request! }

      let! (:order) { create(:order, workshop: workshop) }
      let! (:order_id) { order.id }

      it 'is successful' do
        expect(response).to have_http_status(:success)
      end

      it 'assings the users current workshop' do
        expect(assigns(:workshop)).to eq(workshop)
      end

      it 'assings the selected order' do
        expect(assigns(:order)).to eq(order)
      end
    end

    context 'no order with the given id' do
      before { send_request! }

      it 'fails with not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'no permission to access the order' do
      before { send_request! }

      let! (:order) { create(:order) }
      let! (:order_id) { order.id }

      it 'fails with not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    it_has_behavior 'forbids unauthenticated access'
  end

  describe '#new' do
    def send_request!
      sign_in user if defined?(user) and not user.nil?

      opts = {}
      opts.merge!(day: day) if defined?(day) and not day.nil?
      get :new, opts
    end

    let!(:user) { create(:sales) }

    context 'user is signed in' do
      before { send_request! }

      it 'succeeds' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns :order with an instance of Order' do
        expect(assigns(:order)).to be_kind_of(Order)
      end

      it 'assigns today to :start_date' do
        expect(assigns(:order).start_date).to be_within_same_day(DateTime.now)
      end

      it 'assigns today to :end_date' do
        expect(assigns(:order).end_date).to be_within_same_day(DateTime.now)
      end

      context 'day is provided' do
        let(:day) { to_dashes(2.days.from_now) }

        it 'assigns provided day to :start_date' do
          expect(assigns(:order).start_date).to be_within_same_day(2.days.from_now)
        end

        it 'assigns provided day to :end_date' do
          expect(assigns(:order).end_date).to be_within_same_day(2.days.from_now)
        end
      end
    end

    it_has_behavior 'forbids unauthenticated access'
  end

  describe '#create' do
    def send_request!
      sign_in user if defined?(user) and not user.nil?

      opts = {}
      opts.merge!(order: order_params) if defined?(order_params) and not order_params.nil?
      opts.merge!(client: client_params) if defined?(client_params) and not client_params.nil?
      opts.merge!(car: car_params) if defined?(car_params) and not car_params.nil?
      post :create, opts
    end

    let! (:workshop) { create(:workshop) }
    let! (:user) { create(:sales, workshop: workshop) }

    context 'valid parameters' do
      before { send_request! }

      let (:order_params) {
        attributes_for(:order).
            merge(start_date: to_slashes(1.day.from_now)).
            merge(end_date: to_slashes(2.days.from_now))
      }
      let (:car_params) { attributes_for(:car) }
      let (:client_params) { attributes_for(:client) }

      it 'redirects to index' do
        expect(response).to redirect_to(orders_url(day: to_dashes(1.day.from_now)))
      end

      it 'records were created' do
        expect(Order.count).to eq(1)
        expect(Car.count).to eq(1)
        expect(Client.count).to eq(1)
      end

      it 'Order is associated with Car' do
        expect(Order.last.car).to eq(Car.last)
      end

      it 'Order is associated with Client' do
        expect(Order.last.client).to eq(Client.last)
      end
    end

    context 'invalid parameters' do
      before { send_request! }

      let (:order_params) {
        attributes_for(:order).
            merge(start_date: to_slashes(1.day.from_now)).
            merge(end_date: to_slashes(1.day.ago))
      }
      let (:car_params) { attributes_for(:car) }
      let (:client_params) { attributes_for(:client) }

      it 'succeeds' do
        expect(response).to have_http_status(:success)
      end

      it 'renders template :new' do
        expect(response).to render_template(:new)
      end

      it 'assigns validation errors' do
        expect(assigns(:order_errors)).to_not be_empty
      end

      it 'no records were created' do
        expect(Order.count).to eq(0)
        expect(Car.count).to eq(0)
        expect(Client.count).to eq(0)
      end
    end

    it_has_behavior 'forbids unauthenticated access'
  end

  describe '#update' do
    def send_request!
      sign_in user if defined?(user) and not user.nil?

      opts = {}
      opts.merge!(id: order_id)
      opts.merge!(order: order_params) if defined?(order_params) and not order_params.nil?
      opts.merge!(client: client_params) if defined?(client_params) and not client_params.nil?
      opts.merge!(car: car_params) if defined?(car_params) and not car_params.nil?
      patch :update, opts
    end

    let (:order_id) { 0 }

    let! (:workshop) { create(:workshop) }
    let! (:user) { create(:sales, workshop: workshop) }

    context 'valid parameters' do
      before { send_request! }

      let (:order_params) {
        attributes_for(:order).
            merge(start_date: to_slashes(1.day.from_now)).
            merge(end_date: to_slashes(2.days.from_now))
      }

      let (:car_params) { attributes_for(:car) }
      let (:client_params) { attributes_for(:client) }

      context 'order exists' do
        let! (:order) { create(:order, workshop: workshop) }
        let! (:order_id) { order.id }

        it 'redirects to index' do
          expect(response).to redirect_to(orders_url(day: to_dashes(1.day.from_now)))
        end

        it 'assigns order attributes appropriately' do
          expect(Order.last).to have_attributes(
                                    start_date: be_within_same_day(1.day.from_now),
                                    end_date: be_within_same_day(2.days.from_now),
                                    color: order_params[:color],
                                    description: order_params[:description])
        end

        context 'keep car and client' do
          let (:car_params) { attributes_for(:car).merge(id: order.car.id) }
          let (:client_params) { attributes_for(:client).merge(id: order.client.id) }

          it 'does not create a new client' do
            expect(Client.count).to eq(1)
          end

          it 'does not create a new car' do
            expect(Car.count).to eq(1)
          end
        end

        it 'creates a new client' do
          expect(Client.count).to eq(2)
        end

        it 'creates a new car' do
          expect(Car.count).to eq(2)
        end

        it 'assigns client attributes appropriately' do
          expect(Client.last).to have_attributes(client_params)
        end

        it 'assigns car attributes appropriately' do
          expect(Car.last).to have_attributes(car_params)
        end
      end

      context 'no permission' do
        let! (:order) { create(:order) }
        let! (:order_id) { order.id }

        it 'redirects to index' do
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'order is missing' do
        it 'fails with record not_found' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'invalid parameters' do
      before { send_request! }

      let!(:order) { create(:order, workshop: workshop)}
      let!(:order_id) { order.id }

      let (:order_params) {
        attributes_for(:order).
            merge(start_date: to_slashes(1.day.from_now)).
            merge(end_date: to_slashes(1.day.ago))
      }
      let (:car_params) { attributes_for(:car) }
      let (:client_params) { attributes_for(:client) }

      it 'succeeds' do
        expect(response).to have_http_status(:success)
      end

      it 'renders template :new' do
        expect(response).to render_template(:show)
      end

      it 'assigns validation errors' do
        expect(assigns(:order_errors)).to_not be_empty
      end

      it 'no records were created' do
        expect(Order.count).to eq(1)
        expect(Car.count).to eq(1)
        expect(Client.count).to eq(1)
      end
    end

    it_has_behavior 'forbids unauthenticated access'
  end

  describe '#destroy' do
    def send_request!
      sign_in user if defined?(user) and not user.nil?

      opts = {}
      opts.merge!(id: order_id)
      delete :destroy, opts
    end

    let (:order_id) { 0 }
    it_has_behavior 'forbids unauthenticated access'
  end
end