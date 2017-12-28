class DashboardController < ApplicationController
	before_action :assert_logged_in

	def assert_logged_in
		redirect_to(root_url) unless logged_in?
	end

	def dashboard
		if is_admin?
			redirect_to('/admin')
		else
			render 'participant/dashboard'
		end
	end

end
