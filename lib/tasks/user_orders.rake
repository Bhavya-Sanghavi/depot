namespace :users do
  desc 'Send each user a summary of all their orders'
  task send_orders: :environment do
    User.find_each do |user|
      next if user.orders.empty?

      OrderMailer.all_orders(user).deliver_later
      puts "Email queued for #{user.email}"
    end
  end
end
