class RemoveEndFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :end
  end
end
