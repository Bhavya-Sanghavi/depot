class CategoriesController < ApplicationController
  def index
    @categories = Category.where(parent_id: nil).includes(:sub_categories)
  end
end
