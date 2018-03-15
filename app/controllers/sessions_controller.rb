class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email:params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		# find user.id in the database and put it into session[:user_id]
  		log_in user
      params[:session][:remember_me] ==  '1' ? remember(user) : forget(user)
  		redirect_back_or user
  	else
  		flash[:danger] = 'Invalid email/password combination'
  		render 'new'
   	end
  end

  def destroy
  	log_out if logged_in?
  	redirect_to root_url
  end
end
