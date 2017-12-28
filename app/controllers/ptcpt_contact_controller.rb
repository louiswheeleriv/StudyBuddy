class PtcptContactController < ApplicationController
	before_action :assert_logged_in

	def assert_logged_in
		redirect_to(root_url) unless logged_in?
	end

	def contact
		if is_admin?
			redirect_to('/admin')
		else
			render 'participant/contact'
		end
	end

	def message
		binding.pry
	end

end
