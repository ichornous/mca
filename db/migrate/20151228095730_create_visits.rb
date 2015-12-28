class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.text :name
      t.text :model
      t.datetime :date

      t.timestamps null: false
    end
  end
end
