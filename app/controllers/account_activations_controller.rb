class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # We need to make sure that the user has not been activated, thus using user.activated? If a user has already been
    # activated and a malicious user has the activation link, if it is not !user.activated?, then the malicious user will
    # be granted the access to log in. Therefore, we have to use !ser.activated? here to ensure such illegal access would 
    # not be grangted.
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      #user.update_attribute(:activated,    true)
      #user.update_attribute(:activated_at, Time.zone.now)
      # Refactoring, change the above two lines to
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end

