class UsersController < ApplicationController

  before_action :logged_in_user, only:[:edit, :update, :index, :destroy]
  before_action :correct_user, only:[:edit,:update]
  before_action :admin_user, only: :destroy

  def show
  	@user = User.find(params[:id])
  end

  def index
    @users = User.paginate(page:params[:page])
  end

  def new
  	@user = User.new
  end

  def create
  	# In previous Ruby the code below actually worked, but after 4.0 it requires strong parameters check for security reasons.
  	@user = User.new(user_params)
  	if @user.save
        log_in @user
  	  	flash[:success] = "Welcome to the Sample App!"
  	  	redirect_to @user
  	else
  		render 'new'
  	end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
    # Handle a successful update.
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit"
    end  
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end


  private
    # this is the strong parameter requirement. If we have a column of admin in our database. Some malicious user may send to following
    # request to the database to get access control: patch /users/17?admin=1.. The user_parms method is aimeda at preventing this from happening
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = 'Please log in.'
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
