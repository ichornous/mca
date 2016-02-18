class CreateEventServices < ActiveRecord::Migration
  def change
    create_table :event_services do |t|
      t.belongs_to :event, index: true
      t.belongs_to :service, index: true

      t.timestamps null: false
    end
  end
end
