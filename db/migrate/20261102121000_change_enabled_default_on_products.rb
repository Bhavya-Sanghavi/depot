class ChangeEnabledDefaultOnProducts < ActiveRecord::Migration[8.1]
  def change
    change_column_default :products, :enabled, false
  end
end
