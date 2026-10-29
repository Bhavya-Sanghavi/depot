require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "adding a product creates a line item" do
    cart = Cart.create!
    product = products(:ruby)

    assert_difference("cart.line_items.count", 1) do
      cart.add_product(product).save!
    end
  end

  test "adding the same product increases quantity" do
    cart = Cart.create!
    product = products(:ruby)

    cart.add_product(product).save!
    line_item = cart.line_items.find_by!(product: product)

    assert_no_difference("cart.line_items.count") do
      cart.add_product(product).save!
    end

    assert_equal 2, line_item.reload.quantity
  end
end
