class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :score, inclusion: { in: (0..10).map { |n| n / 2.0 } }
  validates :user_id, uniqueness: { scope: :product_id }
end
