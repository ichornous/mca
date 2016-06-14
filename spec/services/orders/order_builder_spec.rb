describe OrderBuilder do
  describe '#create' do
    before do
      subject.set_workshop(workshop) if defined?(workshop)
      subject.set_attributes(order_attributes) if defined?(order_attributes) and order_attributes
      subject.set_client_attributes(client_attributes) if defined?(client_attributes) and client_attributes
      subject.set_car_attributes(car_attributes) if defined?(car_attributes) and car_attributes
    end

    shared_context 'succeeds' do
      it 'returns a non null result' do
        expect(subject.create).to_not be_nil
      end

      it 'returns an object of type Order' do
        expect(subject.create).to be_a(Order)
      end
    end

    shared_context 'fails gently' do
      it 'returns a null result' do
        expect(subject.create).to be_nil
      end

      it 'populates errors' do
        subject.create

        expect(subject.errors).to_not be_empty
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
        expect(subject.create.try(:workshop)).to eq(workshop)
      end

      it 'assigns order attributes' do
        expect(subject.create).to have_attributes(order_attributes) if order_attributes
      end
    end

    shared_context 'creates client' do
      it 'creates new record in the clients table' do
        expect{ subject.create }.to change(Client, :count).by(1)
      end

      it 'associates the client with the order' do
        expect(subject.create.client).to_not be_nil
      end

      it 'assigns client attributes' do
        expect(subject.create.client).to have_attributes(client_attributes)
      end
    end

    shared_context 'creates car' do
      it 'creates new record in the clients table' do
        expect{ subject.create }.to change(Car, :count).by(1)
      end

      it 'associates the car with the order' do
        expect(subject.create.car).to_not be_nil
      end

      it 'assigns client attributes' do
        expect(subject.create.car).to have_attributes(car_attributes)
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
      let (:workshop) { create(:workshop) }
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

        let (:client_attributes) { client.id }
        let (:car_attributes) { car.id }

        it_has_behavior 'succeeds'
        it_has_behavior 'creates order'
        it_has_behavior 'does not create client'
        it_has_behavior 'does not create car'
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
        let (:client_attributes) { 1 }
        let (:car_attributes) { 1 }

        it_has_behavior 'fails gently'
        it_has_behavior 'reports missing car and client'
      end

      context 'car and client belong to different workshop' do
        let! (:client) { create(:client) }
        let! (:car) { create(:car) }
        let (:client_attributes) { client.id }
        let (:car_attributes) { car.id }

        it_has_behavior 'fails gently'
        it_has_behavior 'reports missing car and client'
      end

      context 'order is invalid' do
        let (:order_attributes) { attributes_for(:order_invalid_fields) }

        it_has_behavior 'fails gently'

        it 'reports order errors' do
          subject.create

          expect(subject.errors).to include(:order)
        end
      end
    end
  end
end
