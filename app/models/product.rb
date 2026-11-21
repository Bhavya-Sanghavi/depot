class Product < ApplicationRecord
    PERMALINK_FORMAT = /\A[a-z0-9]+(?:-[a-z0-9]+){2,}\z/i
    MINIMUM_DESCRIPTION_LENGTH = 5
    MAXIMUM_DESCRIPTION_LENGTH = 10

    has_many :line_items, dependent: :restrict_with_error
    has_many :carts, through: :line_items
    after_initialize :set_default_title, if: :new_record?
    after_validation :set_default_discount_price, on: [ :create, :update ]

    validates :title, :description, :image_url, presence: true
    validates :title, uniqueness: true
    validates :price, numericality: { greater_than_or_equal_to: 0.01 }
    # validates :image_url, url: true, allow_blank: true, format: {
    #     with: /\A.*\.(gif|jpg|png)\z/i,
    #     message: 'must be a URL for GIF, JPG or PNG image.'
    # }
    validates :permalink, uniqueness: true, format: { with: PERMALINK_FORMAT, message: 'must not have special characters or spaces' }, allow_nil: true
    validate :validate_description_length
    validates :price, comparison: { greater_than: :discount_price, message: 'must be greater than discount price' }, if: -> { price.present? && discount_price.present? }
    validates :price, price_greater_than_discount_price: true, if: -> { price.present? && discount_price.present? }

    scope :enabled, -> { where(enabled: true) }
    scope :having_line_items, -> { joins(:line_items).distinct }

    belongs_to :category
    after_commit :update_category_product_counts, on: [ :create, :update, :destroy ]

    has_many_attached :images
    validate :max_3_images

    def self.titles_having_line_items
      having_line_items.pluck(:title)
    end

    private

    def validate_description_length
      return if description.blank?

      word_count = description.split.size

      if word_count < MINIMUM_DESCRIPTION_LENGTH || word_count > MAXIMUM_DESCRIPTION_LENGTH
        errors.add(:description, "must have minimum #{MINIMUM_DESCRIPTION_LENGTH} words and maximum #{MAXIMUM_DESCRIPTION_LENGTH} words")
      end
    end

    def set_default_title
      self.title  = 'abc' if title.blank?
    end

    def set_default_discount_price
      self.discount_price = price unless discount_price.present?
    end

    def update_category_product_counts
      category_ids =
      if destroyed? || previously_new_record?
        [ category_id ]
      elsif saved_change_to_category_id?
        saved_change_to_category_id
      else
        []
      end

      Category.where(id: category_ids.uniq).find_each do |category|
        category.update_product_counts
        category.parent&.update_product_counts
      end
    end

    def max_3_images
      if images.length > 3
        errors.add(:images, 'cannot add more than 3 images')
      end
    end
end
