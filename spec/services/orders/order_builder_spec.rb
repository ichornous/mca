describe OrderBuilder do
  let(:subject) { OrderBuilder.new(workshop) }
  let(:workshop) { create(:workshop) }

  describe '#create' do
    before do
      subject.order_attributes = order_attributes if defined?(order_attributes) and order_attributes
      subject.client_attributes = client_attributes if defined?(client_attributes) and client_attributes
      subject.car_attributes = car_attributes if defined?(car_attributes) and car_attributes
    end

    shared_context 'succeeds' do
      it 'returns a non null result' do
        expect(subject.create).to_not be_falsey
      end
    end

    shared_context 'fails gently' do
      it 'returns a null result' do
        expect(subject.create).to be_falsey
      end

      it_has_behavior 'does not create order'
      it_has_behavior 'does not create client'
      it_has_behavior 'does not create car'
    end

    shared_context 'creates order' do
      it 'creates new record in the orders table' do
        expect{ subject.create }.to change(Order, :count).by(1)
      end

      it 'creates an order in a given workshop' do
        subject.create

        expect(subject.order.try(:workshop)).to eq(workshop)
      end

      it 'assigns order attributes' do
        subject.create

        expect(subject.order).to have_attributes(order_attributes) if order_attributes
      end
    end

    shared_context 'creates client' do
      it 'creates new record in the clients table' do
        expect{ subject.create }.to change(Client, :count).by(1)
      end

      it 'associates saves the newly created client' do
        subject.create

        expect(subject.client).to eq(Client.last)
      end

      it 'associates the client with the order' do
        subject.create

        expect(subject.client).to eq(subject.order.client)
      end

      it 'assigns client attributes' do
        subject.create

        expect(subject.client).to have_attributes(client_attributes)
      end
    end

    shared_context 'creates car' do
      it 'creates new record in the clients table' do
        expect{ subject.create }.to change(Car, :count).by(1)
      end

      it 'associates saves the newly created client' do
        subject.create

        expect(subject.car).to eq(Car.last)
      end

      it 'associates the client with the order' do
        subject.create

        expect(subject.car).to eq(subject.order.car)
      end

      it 'assigns client attributes' do
        subject.create

        expect(subject.car).to have_attributes(car_attributes)
      end
    end

    shared_context 'does not create order' do
      it 'no new order record is added' do
        expect{ subject.create }.to_not change(Order, :count)
      end
    end

    shared_context 'does not create client' do
      it 'no new client record is added' do
        expect{ subject.create }.to_not change(Client, :count)
      end
    end

    shared_context 'does not create car' do
      it 'no new car record is added' do
        expect{ subject.create }.to_not change(Car, :count)
      end
    end

    context 'valid parameters' do
      let (:order_attributes) { attributes_for(:order) }

      context 'create a client and a car' do
        let (:client_attributes) { attributes_for(:client) }
        let (:car_attributes) { attributes_for(:car) }

        it_has_behavior 'succeeds'
        it_has_behavior 'creates order'
        it_has_behavior 'creates client'
        it_has_behavior 'creates car'
      end

      context 'reuse a client and a car' do
        let! (:client) { create(:client, workshop: workshop) }
        let! (:car) { create(:car, workshop: workshop) }

        let (:client_attributes) { attributes_for(:client).merge(id: client.id) }
        let (:car_attributes) { attributes_for(:car).merge(id: car.id) }

        it_has_behavior 'succeeds'
        it_has_behavior 'creates order'
        it_has_behavior 'does not create client'
        it_has_behavior 'does not create car'

        it 'assigns new attributes to client' do
          subject.create

          expect(subject.client).to have_attributes(client_attributes.except(:id))
        end

        it 'assigns new attributes to car' do
          subject.create

          expect(subject.car).to have_attributes(car_attributes.except(:id))
        end
      end
    end

    context 'invalid parameters' do
      let (:workshop) { create(:workshop) }
      let (:order_attributes) { attributes_for(:order) }
      let (:client_attributes) { attributes_for(:client) }
      let (:car_attributes) { attributes_for(:car) }

      shared_context 'reports missing car and client' do
        it 'reports nothing but car and client keys' do
          subject.create

          expect(subject.errors.count).to eq(3)
        end

        it 'reports order validation error' do
          subject.create

          expect(subject.errors).to include(order: include(:client, :car))
        end

        it 'reports a missing client' do
          subject.create

          expect(subject.errors).to include(client: include(id: include(I18n.t('activerecord.errors.models.client.not_found'))))
        end

        it 'reports a missing car' do
          subject.create

          expect(subject.errors).to include(car: include(id: include(I18n.t('activerecord.errors.models.car.not_found'))))
        end
      end

      context 'car and client are missing' do
        let (:client_attributes) { attributes_for(:client).merge(id: 1) }
        let (:car_attributes) { attributes_for(:car).merge(id: 1) }

        it 'fails with not found error' do
          expect {
            subject.create
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'car and client belong to different workshop' do
        let! (:client) { create(:client) }
        let! (:car) { create(:car) }
        let (:client_attributes) { attributes_for(:client).merge(id: client.id) }
        let (:car_attributes) { attributes_for(:car).merge(id: car.id) }

        it 'fails with not found error' do
          expect {
            subject.create
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'order is invalid' do
        let (:order_attributes) { attributes_for(:order_invalid_fields) }

        it_has_behavior 'fails gently'

        it 'reports order errors' do
          subject.create

          expect(subject.order.errors).to include(:end_date)
        end
      end
    end
  end
end
