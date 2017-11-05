class SessionController < ApplicationController

  def new

  end

	def create
		user = User.find_by(username: params[:session][:username].downcase)
    if user && user.authenticate(params[:session][:password])
			log_in(user)
			if user.is_admin
				redirect_to('/admin')
			else
				redirect_to('/dashboard')
			end
    else
			@error = 'Invalid username/password combination'
      render 'new'
    end
  end

	def destroy
    log_out
    redirect_to('/login')
  end

end
