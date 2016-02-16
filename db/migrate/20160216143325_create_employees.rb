class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|      
      t.string :first_name
      t.string :second_name
      t.string :title

      t.timestamps null: false
    end
  end
end
