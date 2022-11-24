# frozen_string_literal: true

# Main user model
class User < ActiveRecord::Base
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def generate_token!
    self.token = SecureRandom.urlsafe_base64(64)
    save!
  end

  def errors
    super.tap { |errors| errors.delete(:password, :blank) unless admin? }
  end

  def as_json(options = {})
    if options.empty?
      super(only: %i[id name email])
    else
      super(options)
    end
  end
end
