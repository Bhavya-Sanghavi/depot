class CategoriesController < ApplicationController
  def index
    @categories = Category.where(parent_id: nil).includes(:sub_categories)
  end

  def books
    @category = Category.find(params[:id])

    category_ids = [ @category.id ] + @category.sub_categories.pluck(:id)

    @products = Product.where(category_id: category_ids)
  end
end
