class Product < ApplicationRecord
    PERMALINK_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/i

    has_many :line_items, dependent: :restrict_with_error
    has_many :carts, through: :line_items
    before_validation :set_default_title, on: [ :create, :update ]
    after_validation :set_default_discount_price, on: [ :create, :update ]

    validates :title, :description, :image_url, presence: true
    validates :title, uniqueness: true
    validates :price, numericality: { greater_than_or_equal_to: 0.01 }
    validates :image_url, url: true, allow_blank: true, format: {
        with: /\A.*\.(gif|jpg|png)\z/i,
        message: 'must be a URL for GIF, JPG or PNG image.'
    }
    validates :permalink, uniqueness: true, format: { with: PERMALINK_FORMAT, message: 'must not have special characters or spaces' }
    validate :permalink_has_minimum_3_words
    validate :description_has_minimum_5_maximum_10_words
    validates :price, comparison: { greater_than: :discount_price, message: 'must be greater than Discount price' }, if: -> { price.present? && discount_price.present? }
    validates :price, price_greater_than_discount_price: true, if: -> { price.present? && discount_price.present? }

    scope :enabled, -> { where(enabled: true) }
    scope :having_line_items, -> { joins(:line_items).distinct }

    belongs_to :category
    after_create :update_category_product_counts
    after_destroy :update_category_product_counts
    after_update :update_category_product_counts, if: :saved_change_to_category_id?

    def self.titles_having_line_items
      having_line_items.pluck(:title)
    end

    private

    def permalink_has_minimum_3_words
      return if permalink.blank?

      words = permalink.split('-')

      if words.length < 3
        errors.add(:permalink, 'must have minimum 3 words seperated by hyphen')
      end
    end

    def description_has_minimum_5_maximum_10_words
      return if description.blank?

      word_count = description.split.size

      if word_count < 5 || word_count > 10
        errors.add(:description, 'must have minimum 5 words and maximum 10 words')
      end
    end

    def set_default_title
      self.title  = 'abc' if title.blank?
    end

    def set_default_discount_price
      self.discount_price = price unless discount_price.present?
    end

    def update_category_product_counts
      category&.update_product_counts
      category&.parent&.update_product_counts
    end
end
