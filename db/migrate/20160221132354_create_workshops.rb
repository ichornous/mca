class CreateWorkshops < ActiveRecord::Migration
  def change
    create_table :workshops do |t|
      t.string :description
      t.timestamps null: false
    end

    add_reference(:events, :workshop, polymorphic: false, index: true)
    add_reference(:users, :workshop, polymorphic: false, index: true)
  end
end
