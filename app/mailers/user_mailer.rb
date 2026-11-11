class UserMailer < ApplicationMailer
  default from: "welcome@example.com"

  def welcome
    @user = params[:user]

    mail to: @user.email, subject: "Welcome"
  end
end
