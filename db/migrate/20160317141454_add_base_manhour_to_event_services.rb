class AddBaseManhourToEventServices < ActiveRecord::Migration
  def change
    add_column :event_services, :manhour, :decimal
    add_column :event_services, :price, :decimal
  end
end
