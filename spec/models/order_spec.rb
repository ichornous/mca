require 'rails_helper'

describe Order, type: :model do
  describe '.in_workshop' do
    let (:ws_1) { create(:workshop) }
    let (:ws_2) { create(:workshop) }
    let (:ws_1_order) { create_list(:order, 3, workshop: ws_1)}
    let (:ws_2_order) { create_list(:order, 3, workshop: ws_2)}

    before do
      ws_1_order
      ws_2_order
    end

    it 'returns orders scheduled in a given workshop' do
      expect(Order.in_workshop(ws_1)).to include(*ws_1_order)
    end

    it 'does not return orders scheduled in other workshops' do
      expect(Order.in_workshop(ws_1)).to_not include(*ws_2_order)
    end
  end

  describe '.in_range' do
    context 'simple cases' do
      let! (:past_orders) { create_list(:order_in_range, 4, start_date: 4.days.ago, end_date: 1.day.ago) }
      let! (:future_orders) { create_list(:order_in_range, 4, start_date: 1.day.from_now, end_date: 4.days.from_now) }

      it 'returns orders which lie in the given range' do
        expect(Order.in_range(4.days.ago, 0.days.from_now)).to include(*past_orders)
      end

      it 'does not return orders which lie outside of the range' do
        expect(Order.in_range(4.days.ago, 0.days.from_now)).to_not include(*future_orders)
      end
    end

    context 'edge cases' do
      let! (:order) { create(:order, start_date: 0.days.from_now, end_date: 4.days.from_now)}

      it 'returns past orders which intersect the range' do
        expect(Order.in_range(2.days.from_now, 6.days.from_now)).to include(order)
      end

      it 'returns past orders which end in the first day of the range' do
        expect(Order.in_range(4.days.from_now, 6.days.from_now)).to include(order)
      end

      it 'returns future orders which intersect the range' do
        expect(Order.in_range(2.days.ago, 2.days.from_now)).to include(order)
      end

      it 'returns future orders which start in the last day of the range' do
        expect(Order.in_range(2.days.ago, 0.days.from_now)).to include(order)
      end
    end
  end

  describe '#valid?' do
    let (:ws) { create(:workshop)}

    it 'should have a valid factory' do
      expect(build(:order)).to be_valid
    end

    it 'is invalid if workshop is not set' do
      expect(build(:order, workshop: nil)).to be_invalid
    end

    it 'is invalid if car is not set' do
      expect(build(:order, car: nil)).to be_invalid
    end

    it 'is invalid if client is not set' do
      expect(build(:order, client: nil)).to be_invalid
    end

    it 'is invalid if color is not set' do
      expect(build(:order, color: nil)).to be_invalid
    end

    it 'is invalid if the color is not in the list of allowed colors' do
      expect(build(:order, color: '#ffffff')).to_not be_valid
    end

    it 'is valid if the color is from the list of allowed colors' do
      Order.event_colors.each do |c|
        expect(build(:order, color: c)).to be_valid
      end
    end

    it 'is invalid if the end date is less then the start date' do
      expect(build(:order, start_date: Date.today, end_date: 1.day.ago)).to_not be_valid
    end

    it 'notifies inconsistent error if the end date is less then the start date' do
      expect(build(:order, start_date: Date.today, end_date: 1.day.ago).errors_on(:end_date)).
          to include(I18n.t('activerecord.errors.models.order.date_range_invalid'))
    end
  end
end
