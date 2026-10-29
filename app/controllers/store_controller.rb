class StoreController < ApplicationController
  skip_before_action :authorize

  include CurrentCart
  before_action :set_cart
  def index
    @products = Product.order(:title)
    @page_title = "Your Pragmatic Catalog"
  end
end
