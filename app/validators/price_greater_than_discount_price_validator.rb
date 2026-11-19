class PriceGreaterThanDiscountPriceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    discount_price = record.discount_price

    return if value.blank? || discount_price.blank?

    unless value > discount_price
      record.errors.add(attribute, 'must be greater than discount price')
    end
  end
end
