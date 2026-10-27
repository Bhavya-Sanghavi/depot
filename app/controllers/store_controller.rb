class StoreController < ApplicationController
  include CurrentCart
  before_action :set_cart
  def index
    @products = Product.order(:title)
    @page_title = "Your Pragmatic Catalog"
  end
end
