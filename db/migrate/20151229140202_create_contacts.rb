class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :type
      t.text :value
      t.text :info
      t.references :visit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
