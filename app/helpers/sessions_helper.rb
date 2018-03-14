require 'pp'
module SessionsHelper


# Logs in the given user
def log_in(user)
  session[:user_id] = user.id
end

def remember(user)
  user.remember
  cookies.permanent.signed[:user_id] = user.id
  cookies.permanent[:remember_token] = user.remember_token
end



# Returns the current logged-in user (if any)
def current_user
  if (user_id = session[:user_id]) 
    @current_user ||= User.find_by(id: user_id)
  elsif (user_id = cookies.signed[:user_id])
  	user = User.find_by(id: user_id)
    # 質問：　どうして user.authenticated?(cookies[:remember_token] returns false????????)

    #cookies[:remember_token] is proved to be the same as user.remember_token
    pp "--------the cookies remember token is-----------"
    pp cookies[:remember_token]


  	if user && user.authenticated?(cookies[:remember_token])
  	  log_in user
  	  @current_user = user
  	end
  end
end

def logged_in?
  !current_user.nil?
end


def forget(user)
  # Set the remember_digest columnn to nil
  user.forget
  cookies.delete(:user_id)
  cookies.delete(:remember_token)
end

def log_out
  session.delete(:user_id)
  @current_user = nil
end


end
