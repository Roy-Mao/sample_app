class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  def new
  end

  def edit
  end

  def create
  	@user = User.find_by(email:params[:password_reset][:email].downcase)
  	if @user
  	  @user.create_reset_digest
  	  @user.send_password_reset_email
  	  flash[:info] = 'Email sent with password reset instructions'
  	  redirect_to root_url
  	else
  	  flash.now[:danger] = "Email address not found"
  	  render 'new'
    end
  end

  def update
    if params[:user][:password].empty?
      # Resulting message is automatically rendered in the correct language when using the rails-i18n gem
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      # he password reset link remains active for 2 hours and can be used even if logged out.
      #If a user reset their password from a public machine, anyone could press the back button
      # and change the password (and get logged in to the site), we write the following one line of code to fix this security concern
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset"
      redirect_to @user
    else
      render 'edit'
    end
      

  end



  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end

end
