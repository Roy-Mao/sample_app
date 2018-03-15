class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length:{ maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length:{ maximum: 255 }, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  # Returns the hash digest of the given string
  def User.digest(string)
  	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
  	BCrypt::Password.create(string, cost: cost)
  end


  # This is one way of defining a class method, there are the other following ways to define class method
  # one is to use self.digest. The other way is to use class << self
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions
  # Generating a new user, digest it and then save it into the database
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # The model is basically used for the interaction with the database, server-side
  # While the controller is basically used for the interaction with the browser, client-side
  def forget
    
    update_attribute(:remember_digest, nil)
  end
end
