class CombineItemsInCart < ActiveRecord::Migration[8.1]
  def up
    # Replace multiple items for a single product in a cart
    # with a single item.
    Cart.all.each do |cart|
      # Count the quantity of each product in the cart.
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity|
        if quantity > 1
          # Remove individual items for this product.
          cart.line_items.where(product_id: product_id).delete_all

          # Replace them with a single item.
          item = cart.line_items.build(product_id: product_id)
          item.quantity = quantity
          item.save!
        end
      end
    end
  end
  def down
    # Split items with quantity > 1 into multiple items.
    LineItem.where("quantity>1").each do |line_item|
      # Add individual items.
      line_item.quantity.times do
        LineItem.create(
          cart_id: line_item.cart_id,
          product_id: line_item.product_id,
          quantity: 1
        )
      end

      # Remove the original item.
      line_item.destroy
    end
  end
end
