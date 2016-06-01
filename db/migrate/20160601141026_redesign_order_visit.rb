class RedesignOrderVisit < ActiveRecord::Migration
  def change
    rename_table :visits, :bookings

    # Ensure one-to-one relationship with orders
    remove_index :bookings, :order_id
    add_index :bookings, :order_id, unique: true

    # Referencing a workshop is no longer needed
    remove_index :bookings, :workshop_id
    remove_column :bookings, :workshop_id

    remove_column :bookings, :client_name
    remove_column :bookings, :car_name
    remove_column :bookings, :phone_number
    remove_column :bookings, :returning
  end
end
