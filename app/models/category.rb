class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :sub_categories, class_name: 'Category', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  has_many :products, dependent: :restrict_with_error
  has_many :sub_category_products, through: :sub_categories, source: :products

  validates :name, presence: true
  validates :name, uniqueness: true, if: -> { name.present? && parent_id.nil? }
  validates :name, uniqueness: { scope: :parent_id }, if: -> { name.present? && parent_id.present? }
  validate :subcategory_cant_have_child_category

  before_destroy :prevent_destroy_if_subcategories_have_products

  def all_products
    Product.where(category_id: [ id, *sub_category_ids ])
  end

  def update_product_counts
    update_column(:products_count, products.count + sub_categories.joins(:products).count)
  end

  private

  def subcategory_cant_have_child_category
    return unless parent&.parent_id.present?

    errors.add(:parent, 'cannot be a subcategory')
  end

  def prevent_destroy_if_subcategories_have_products
    return unless sub_categories.joins(:products).exists?

    errors.add(:base, 'Cannot delete category because its subcategories have products')
    throw :abort
  end
end
