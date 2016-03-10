class AddDurationAndColorToEvents < ActiveRecord::Migration
  def change
    add_column :events, :duration, :time
    add_column :events, :color, :string
  end
end
