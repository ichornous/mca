class RemoveCostFromServices < ActiveRecord::Migration
  def change
    remove_column :services, :time, :decimal
  end
end
