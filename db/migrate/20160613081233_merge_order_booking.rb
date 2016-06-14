class MergeOrderBooking < ActiveRecord::Migration
  def up
    add_column :orders, :description, :string
    add_column :orders, :color, :string
    add_column :orders, :start_date, :datetime
    add_column :orders, :end_date, :datetime

    if defined?(Booking) and defined?(Order)
      Booking.all().each do |booking|
        booking.order.description = booking.description
        booking.order.color = booking.color
        booking.order.start_date = booking.start_date
        booking.order.end_date = booking.end_date
        booking.order.save!
      end
    end

    remove_index :bookings, :order_id
    drop_table :bookings
  end

  def down
    create_table :bookings do |t|
      t.belongs_to :order, index: true
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.string :color
    end

    if defined?(Booking) and defined?(Order)
      Order.all().each do |order|
        Booking.create(
            order_id: order.id,
            description: order.description,
            color: order.color,
            start_date: order.start_date,
            end_date: order.end_date)
      end
    end

    remove_column :orders, :description
    remove_column :orders, :color
    remove_column :orders, :start_date
    remove_column :orders, :end_date
  end
end
