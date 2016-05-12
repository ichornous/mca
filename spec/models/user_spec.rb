require 'rails_helper'

describe User, type: :model do
  describe '#can_assign_role?' do
    context 'user is in role :sales' do
      let (:user) { create(:sales) }
      it { expect(user.can_assign_role?(:sales)).to eq(true) }
      it { expect(user.can_assign_role?(:manager)).to eq(false) }
      it { expect(user.can_assign_role?(:admin)).to eq(false) }
    end

    context 'user is in role :manager' do
      let (:user) { create(:manager) }
      it { expect(user.can_assign_role?(:sales)).to eq(true) }
      it { expect(user.can_assign_role?(:manager)).to eq(true) }
      it { expect(user.can_assign_role?(:admin)).to eq(false) }
    end

    context 'user is in role :admin' do
      let (:user) { create(:admin) }
      it { expect(user.can_assign_role?(:sales)).to eq(true) }
      it { expect(user.can_assign_role?(:manager)).to eq(true) }
      it { expect(user.can_assign_role?(:admin)).to eq(true) }
    end
  end

  describe '#impersonate' do
    let (:workshop) { create(:workshop) }

    context 'user is in role :sales' do
      let (:user) { create(:sales) }

      it { expect(user.impersonate(workshop)).to eq(false) }
      it { expect{user.impersonate(workshop)}.to_not change{user.current_workshop} }
      it { expect{user.impersonate(workshop)}.to_not change{user.is_impersonated?} }
    end

    context 'user is in role :manager' do
      let (:user) { create(:manager) }

      it { expect(user.impersonate(workshop)).to eq(false) }
      it { expect{user.impersonate(workshop)}.to_not change{user.current_workshop} }
      it { expect{user.impersonate(workshop)}.to_not change{user.is_impersonated?} }
    end

    context 'user is in role :admin' do
      let (:user) { create(:admin) }

      it { expect(user.impersonate(workshop)).to eq(true) }
      it { expect{user.impersonate(workshop)}.to change{user.current_workshop}.from(user.workshop).to(workshop) }
      it { expect{user.impersonate(workshop)}.to change{user.is_impersonated?}.from(false).to(true) }
    end
  end
end
