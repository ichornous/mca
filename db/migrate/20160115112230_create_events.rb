class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.string :client_name
      t.string :phone_number
      t.datetime :start
      t.datetime :end

      t.timestamps null: false
    end
  end
end
