class AddUserToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :user
  end
end
