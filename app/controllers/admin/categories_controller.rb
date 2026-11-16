module Admin
  class CategoriesController < BaseController
    def index
      @categories = Category.includes(:parent).order(:name)
    end
  end
end