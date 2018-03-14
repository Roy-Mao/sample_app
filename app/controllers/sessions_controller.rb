class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by(email:params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		# find user.id in the database and put it into session[:user_id]
  		log_in user
      params[:session][:remember_me] ==  '1' ? remember(user) : forget(user)
  		# user.remember put the digested remember_token into the database
  		# put the signed user_id into the browser cookies[:user_id]
  		# put the hashed remember_token into the brwoser cookie[:remember_token]
  		# remember user
  		redirect_to user
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
