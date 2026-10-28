require "test_helper"

class LineItemTest < ActiveSupport::TestCase
  test "quantity must be greater than zero" do
    line_item = LineItem.new(
      product: products(:ruby),
      quantity: 0
    )

    assert line_item.invalid?
    assert_includes line_item.errors[:quantity],
      "must be greater than 0"
  end
end
