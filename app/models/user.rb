class User < ApplicationRecord
  # A user can have many microposts. has_many by default will change :microposts to Micropost model and then build the relationship
  # When we do user.microposts.build/create. Here, the two models are connected by the defualt user_id column (foreign key), which is very different from the following code,
  # in which we have to specify the class name and the foreign key 'follower_id'
  has_many :microposts, dependent: :destroy
  # However, in the following code, we write has_many :active_relationships instead of relationships. Therefore, we need to tell Rails explicitly the model class name to look for
  # Here, we do user.active_relationships..By default, if we do not specify class name and the foreign key explicitly. Rails will look for ActiveRelationship model and a foreign key
  # whose name is user_id. Since ActiveRelationship model does not exist, we need to specify 'Relationship'. Since there is no user_id in the Relationship table
  # We need to specify the foreign_key as the follower_id.
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id",dependent: :destroy
  # should have been 'has_many :followeds, through: :active_relationships'
  # Which defines user.followeds through the :active_relationships association. Rails first change :followeds to followed_id
  # It returns a collection of objects determined with followed_id by providing the foreign_key follower_id of the user
  # If we wanna change user.followeds to user.folloing. we add the following code by specifying the source is singular followed(_id)
  has_many :following, through: :active_relationships, source: :followed
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # The source: :follower part can be ommited, because Rails is configured by deault to use :followers. Change it to singular form and add _id at the end.
  has_many :followers, through: :passive_relationships
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

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
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
    #update_attribute(:reset_digest, User.digest(reset_token))
    #update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Defines a proto-feed
  # See "Following users" for the full implementation
  def feed
    #Micropost.where("user_id = ?", id)
    # Returns a user's status feed
    #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end

  # Follows a user
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user
  def following?(other_user)
    following.include?(other_user)
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
