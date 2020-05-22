class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  # username validation
  VALID_USERNAME_REGEX = /\A[a-zA-Z]+([\w\d-]+)*\z/i
  validates :name, presence: true, length: { maximum: 50 }
  # email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.([a-z]+){2}\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true
  # password and encryption validation
  has_secure_password
  validates :password, presence: true, length: { minimum: 8 }, allow_nil: true

  # returns a hash digest
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # returns a random token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # remember a user in database for persistent session
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # does given token match digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # forget user
  def forget
    update_attribute(:remember_digest, nil)
  end
end
