class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :product, presence: true
  validates :product_id, uniqueness: { scope: :cart_id }

  def total_price
    price * quantity
  end
end
