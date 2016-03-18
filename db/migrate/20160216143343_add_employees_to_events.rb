class AddEmployeesToEvents < ActiveRecord::Migration
  def change
    create_table :employees_events, id: false do |t|
      t.belongs_to :visit, index: true
      t.belongs_to :employee, index: true
    end
  end
end
