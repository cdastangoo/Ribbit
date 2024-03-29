class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
           foreign_key: "follower_id",
           dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
           foreign_key: "followed_id",
           dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save { email.downcase! }
  before_create :create_activation_digest
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

  # returns username attribute to construct URL path
  # def to_param
  #   "#{self.name}"
  # end

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

  # returns true if given token matches digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # forget user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # activate account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # set password reset attributes
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # send password reset email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # returns true if password reset is expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # show user feed
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Post.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end

  # follows a user
  def follow(other_user)
    following << other_user
  end

  # unfollows a user
  def unfollow(other_user)
    following.delete(other_user)
  end

  # returns true if following given user
  def following?(other_user)
    following.include?(other_user)
  end

  private

    # create and assign activation token and digest
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
