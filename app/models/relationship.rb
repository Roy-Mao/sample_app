class Relationship < ApplicationRecord
  # However, the following two lines of code are different from the code in Micropost model
  # Rails will first change :follower to follower_id and :followed to followed_id and see if it exists in the current model
  # It does exist in the Relationship model. If we do not specify the class name. Rails will infer the asscociation between Relationship model and Follower or Following model respectively, just like 'belongs_to :user' does, which is not what we want.
  # Therefore, it is necessary here to add class_name "User" to specify the model which we want to associate with.
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
