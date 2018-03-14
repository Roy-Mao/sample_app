class UsersController < ApplicationController
  def show
  	@user = User.find(params[:id])
  end

  def new
  	@user = User.new
  end

  def create
  	# In previous Ruby the code below actually worked, but after 4.0 it requires strong parameters check for security reasons.
  	@user = User.new(user_params)
  	if @user.save
  	  	#Handle a successful save
        log_in @user
  	  	flash[:success] = "Welcome to the Sample App!"
  	  	redirect_to @user
  	else
  		render 'new'
  	end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
