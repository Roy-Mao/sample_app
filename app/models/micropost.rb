class Micropost < ApplicationRecord
  # Here inside the Micropost model, there is a column called user_id. And Rails, by default, expects the foreign key to be of the fomr like <class>_id.
  # If we write belongs_to :user. Rails will first change :user to user_id as the foreign key and see if this column exist in the model.
  # Here user_id is a column of the Micropost model, so the asscociation between User model and Micropost model is inferred automatically.
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size


  private

  # Validate the size of an uploaded picture
  def picture_size
  	if picture.size > 5.megabytes
  	  errors.add(:picture, "should be less than 5MB")
  	end
  end
end
