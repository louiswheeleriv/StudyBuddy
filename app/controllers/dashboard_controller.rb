class DashboardController < ApplicationController
	before_action :assert_logged_in

	def assert_logged_in
		redirect_to(root_url) unless logged_in?
	end

	def dashboard
		redirect_to('/admin') if is_admin?
	end

end
