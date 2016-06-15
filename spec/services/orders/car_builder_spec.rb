describe CarBuilder do
  let(:subject) { CarBuilder.new(workshop) }
  let(:workshop) { create(:workshop) }

  describe '#build' do
    shared_context 'does not create a new car' do
      it 'does not insert a record into the cars table' do
        expect{ subject.build(car_params) rescue nil }.to_not change(Car, :count)
      end
    end

    shared_context 'builds a new instance of Car' do
      it 'returns an instance of class Car' do
        expect(subject.build(car_params)).to be_kind_of(Car)
      end
    end

    shared_context 'assigns attributes to the instance' do
      it 'should assing supplied attributes to the instance' do
        expect(subject.build(car_params)).to have_attributes(car_params.except(:id))
      end
    end

    shared_context 'locates an existing car with the same id' do
      it 'returns a record from the cars table' do
        expect(subject.build(car_params).id).to eq(car.id)
      end
    end

    shared_context 'reports missing record' do
      it 'raises not found error' do
        expect{subject.build(car_params)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'valid car information provided' do
      context 'new car' do
        let (:car_params) { attributes_for(:car) }

        it_has_behavior 'does not create a new car'
        it_has_behavior 'builds a new instance of Car'
        it_has_behavior 'assigns attributes to the instance'
      end

      context 'existing car' do
        let! (:car) { create(:car, workshop: workshop) }
        let (:car_params) { attributes_for(:car).merge(id: car.id) }

        it_has_behavior 'does not create a new car'
        it_has_behavior 'locates an existing car with the same id'
        it_has_behavior 'assigns attributes to the instance'
      end
    end

    context 'invalid information provided' do
      context 'car is missing' do
        let (:car_params) { attributes_for(:car).merge(id: 1) }

        it_has_behavior 'does not create a new car'
        it_has_behavior 'reports missing record'
      end

      context 'car belongs to a different workshop' do
        let! (:car) { create(:car) }
        let (:car_params) { attributes_for(:car).merge(id: car.id) }

        it_has_behavior 'does not create a new car'
        it_has_behavior 'reports missing record'
      end
    end
  end
end
