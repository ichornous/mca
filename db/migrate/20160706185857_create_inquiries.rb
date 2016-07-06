class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.datetime :date
      t.references :workshop, index: true, foreign_key: true
      t.references :client, index: true, foreign_key: true
      t.references :car, index: true, foreign_key: true
      t.string :description
      t.integer :color

      t.timestamps null: false
    end

    add_reference :orders, :inquiry, index: true
  end
end
