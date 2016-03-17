class AddBaseManhourToServices < ActiveRecord::Migration
  def change
    add_column :services, :manhour, :datetime
  end
end
