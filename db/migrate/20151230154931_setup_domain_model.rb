class SetupDomainModel < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.decimal :base_cost
      t.decimal :base_time

      t.timestamps null: false
    end

    create_table :clients do |t|
      t.string :name
      t.string :phone

      t.timestamps null: false
    end

    create_table :cars do |t|
      t.string :description
      t.string :license_id
      t.string :photo
    end

    create_table :orders do |t|
      t.belongs_to :workshop, index: true
      t.belongs_to :client, index: true
      t.belongs_to :car, index: true
      t.string :state
      t.timestamps null: false
    end

    create_table :order_services do |t|
      t.belongs_to :order, index: true
      t.belongs_to :service, index: true
      t.decimal :cost
      t.decimal :time
      t.timestamps null: false
    end

    create_table :workshops do |t|
      t.string :description
      t.string :color
      t.timestamps null: false
    end

    create_table :visits do |t|
      t.belongs_to :order, index: true
      t.boolean :returning
      t.text :description
      t.string :client_name
      t.string :phone_number
      t.datetime :date
      t.string :color
      t.timestamps null: false
    end
  end
end