require 'uri'

class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true, uniqueness: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'must be in form of valid email address' }
  after_destroy :ensure_an_admin_remains
  after_create :send_welcome_email
  before_destroy :prevent_admin_delete
  before_update :prevent_admin_update
  has_many :orders
  has_many :line_items, through: :orders
  
  class Error < StandardError
  end

  private

  def ensure_an_admin_remains
    if User.count.zero?
      raise Error, "Can't delete last user"
    end
  end
  def send_welcome_email
    UserMailer.with(user: self).welcome.deliver_now
  end

  def prevent_admin_delete
    if email == "admin@depot.com"
      errors.add(:base, "Cannot delete admin")
      throw :abort
    end
  end

  def prevent_admin_update
    if email == "admin@depot.com"
      errors.add(:base, "Cannot update admin")
      throw :abort
    end
  end
end
