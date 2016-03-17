class RemoveCostFromServices < ActiveRecord::Migration
  def change
    remove_column :services, :cost, :decimal
    remove_column :services, :time, :decimal
  end
end
