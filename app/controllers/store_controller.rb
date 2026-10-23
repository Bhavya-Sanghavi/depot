class StoreController < ApplicationController
  def index
    @products = Product.order(:title)
    @page_title = "Your Pragmatic Catalog"
  end
end
