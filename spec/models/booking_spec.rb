require 'rails_helper'

describe Booking, type: :model do
  describe 'factories' do
    context 'factory visit_with_order' do
      let (:booking) { create(:booking_with_order) }

      it 'assigns an order' do
        expect(booking.order).to_not be_nil
      end

      it 'assigns order items' do
        expect(booking.order.order_services.count).to eq(3)
      end

      it 'assigns the order to each order item' do
        expect(booking.order.order_services).to_not include(not_have_attributes(orders: booking.order))
      end

      it 'persists an order' do
        expect(Booking.find(booking.id).order).to_not be_nil
      end

      it 'persists order items' do
        expect(OrderService.where(order_id: booking.order.id).count).to eq(3)
      end
    end
  end

  describe '.in_workshop' do
    let (:ws_1) { create(:workshop) }
    let (:ws_2) { create(:workshop) }
    let (:ws_1_bookings) { create_list(:booking_with_order, 3, order_workshop: ws_1)}
    let (:ws_2_bookings) { create_list(:booking_with_order, 3, order_workshop: ws_2)}

    before do
      ws_1_bookings
      ws_2_bookings
    end

    it 'returns bookings scheduled in a given workshop' do
      expect(Booking.in_workshop(ws_1)).to include(*ws_1_bookings)
    end

    it 'does not return bookings scheduled in other workshops' do
      expect(Booking.in_workshop(ws_1)).to_not include(*ws_2_bookings)
    end
  end

  describe '.in_range' do
    it 'does not return visits which are not intersected with `start` and `end`' do
      v1 = create(:booking, :started_4days_ago, :last_4days)
      v2 = create(:booking, :started_4days_from_now, :last_4days)

      result = Booking.in_range(1.day.from_now, 2.days.from_now)

      expect(result).to_not include(v1, v2)
    end

    it 'returns visits which are scheduled between `start` and `end`' do
      v1 = create(:booking)

      result = Booking.in_range(1.week.ago, 1.week.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits which start before `start` and end after `start`' do
      v1 = create(:booking, :last_4days)

      result = Booking.in_range(Date.today, 1.week.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits which are scheduled before `end` and end after `end`' do
      v1 = create(:booking, :last_4days)

      result = Booking.in_range(1.week.ago, Date.today)

      expect(result).to include(v1)
    end

    it 'returns visits which are scheduled before `start` and end after `end`' do
      v1 = create(:booking, :started_4days_ago, :last_8days)

      result = Booking.in_range(1.day.ago, 1.day.from_now)

      expect(result).to include(v1)
    end

    it 'returns visits including the start date' do
      v1 = create(:booking)

      result = Booking.in_range(1.day.ago, 1.day.ago)

      expect(result).to include(v1)
    end

    it 'returns visits including the end date' do
      v1 = create(:booking)

      result = Booking.in_range(1.day.from_now, 1.day.from_now)

      expect(result).to include(v1)
    end
  end

  describe '#valid?' do
    let (:ws) { create(:workshop)}

    it 'should have a valid factory' do
      expect(build(:booking)).to be_valid
    end

    it 'is valid if the color is from the list of allowed colors' do
      Booking.event_colors.each do |c|
        expect(build(:booking, color: c)).to be_valid
      end
    end

    it 'is invalid if the order attribute is not given' do
      expect(build(:booking, orders: nil)).to be_invalid
    end

    it 'is invalid if the end date is less then the start date' do
      expect(build(:booking, start_date: Date.today, end_date: 1.day.ago)).to_not be_valid
    end

    it 'is invalid if the color is not in the list of allowed colors' do
      expect(build(:booking, color: '#ffffff')).to_not be_valid
    end

    it 'notifies inconsistent error if the end date is less then the start date' do
      expect(build(:booking, start_date: Date.today, end_date: 1.day.ago).errors_on(:end_date)).
          to include(I18n.t('activerecord.errors.orders.booking.date_range_invalid'))
    end

    it 'notifies inconsistent error if the booking`s order is not set' do
      expect(build(:booking, orders: nil).errors_on(:orders)).
          to include(I18n.t('activerecord.errors.models.booking.attributes.order.blank'))
    end
  end
end
