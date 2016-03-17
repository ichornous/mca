class AddBaseManhourToServices < ActiveRecord::Migration
  def change
    add_column :services, :manhour, :decimal
  end
end
