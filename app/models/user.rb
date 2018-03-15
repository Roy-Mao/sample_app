class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  #before_save { email.downcase! }, we can change this to
  before_save :downcase_email
  before_create :create_activation_digest

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
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # The model is basically used for the interaction with the database, server-side
  # While the controller is basically used for the interaction with the browser, client-side
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account
  def activate
    # These belowing two codes are going to hit the databse twice, we can utilize 
    #update_attribute(:activated, true)
    #update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end


  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # No need to expose the following methods to the outside world
  private

  def downcase_email
    self.email = email.downcase
  end

  # Create and assigns the activatio token and digest
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
