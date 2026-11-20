class LineItem < ApplicationRecord
  belongs_to :order, optional: true
  belongs_to :product
  belongs_to :cart, optional: true, counter_cache: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :product, presence: true
  validates :product_id, uniqueness: { scope: :cart_id }, allow_nil: true, if: -> { cart_id.present? }


  def total_price
    price * quantity
  end
end
