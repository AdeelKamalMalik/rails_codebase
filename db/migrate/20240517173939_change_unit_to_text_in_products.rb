class ChangeUnitToTextInProducts < ActiveRecord::Migration[7.1]
  def change
    change_column :products, :unit, :text
  end
end
