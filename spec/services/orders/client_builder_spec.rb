describe ClientBuilder do
  let(:subject) { ClientBuilder.new(workshop) }
  let(:workshop) { create(:workshop) }

  describe '#build' do
    shared_context 'does not create a new client' do
      it 'does not insert a record into the clients table' do
        expect{ subject.build(client_params) rescue nil }.to_not change(Client, :count)
      end
    end

    shared_context 'builds a new instance of Client' do
      it 'returns an instance of class Client' do
        expect(subject.build(client_params)).to be_kind_of(Client)
      end
    end

    shared_context 'assigns attributes to the instance' do
      it 'should assing supplied attributes to the instance' do
        expect(subject.build(client_params)).to have_attributes(client_params.except(:id))
      end
    end

    shared_context 'locates an existing client with the same id' do
      it 'returns a record from the clients table' do
        expect(subject.build(client_params).id).to eq(client.id)
      end
    end

    shared_context 'reports missing record' do
      it 'raises not found error' do
        expect{subject.build(client_params)}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'valid client information provided' do
      context 'new client' do
        let (:client_params) { attributes_for(:client) }

        it_has_behavior 'does not create a new client'
        it_has_behavior 'builds a new instance of Client'
        it_has_behavior 'assigns attributes to the instance'
      end

      context 'existing client' do
        let! (:client) { create(:client, workshop: workshop) }
        let (:client_params) { attributes_for(:client).merge(id: client.id) }

        it_has_behavior 'does not create a new client'
        it_has_behavior 'locates an existing client with the same id'
        it_has_behavior 'assigns attributes to the instance'
      end
    end

    context 'invalid information provided' do
      context 'client is missing' do
        let (:client_params) { attributes_for(:client).merge(id: 1) }

        it_has_behavior 'does not create a new client'
        it_has_behavior 'reports missing record'
      end

      context 'client belongs to a different workshop' do
        let! (:client) { create(:client) }
        let (:client_params) { attributes_for(:client).merge(id: client.id) }

        it_has_behavior 'does not create a new client'
        it_has_behavior 'reports missing record'
      end
    end
  end
end
