namespace :products do
  desc 'Assign legacy products to the first category'
  task port_legacy_products: :environment do
    category = Category.order(:id).first

    if category.nil?
      abort 'No categories found. Please create a category first.'
    end

    products = Product.where(category_id: nil)
    count = products.count

    products.update_all(category_id: category.id)

    Category.find_each(&:update_product_counts)

    puts "#{count} products assigned to #{category.name}"
  end
end
