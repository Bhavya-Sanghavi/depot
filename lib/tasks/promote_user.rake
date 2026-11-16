namespace :users do
  desc 'Promote a user to admin'
  task :promote_to_admin, [ :email ] => :environment do |_task, args|
    user = User.find_by(email: args[:email])

    if user
      user.update!(role: 'admin')
      puts "#{user.email} is now an admin."
    else
      puts "User with email #{args[:email]} not found."
    end
  end
end
