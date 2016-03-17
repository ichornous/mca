class AddBaseManhourToEventServices < ActiveRecord::Migration
  def change
    add_column :event_services, :manhour, :datetime
    add_column :event_services, :price, :decimal
  end
end
