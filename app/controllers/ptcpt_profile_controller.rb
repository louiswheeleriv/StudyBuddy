class PtcptProfileController < ApplicationController
	before_action :assert_logged_in

	def assert_logged_in
		redirect_to(root_url) unless logged_in?
	end

	def profile
		if is_admin?
			redirect_to('/admin')
		else
			@user = User.find(current_user.id)
			render 'participant/profile'
		end
	end

	def update
		updates = params['updates'].to_unsafe_h
		user = User.find(current_user.id)
		if updates['current_password'] || updates['password'] || updates['password_confirmation']
			validation = validate_password_info(updates, user)
			if !validation[:valid]
				render status: 401, json: { error: validation[:error] } and return
			end
		end
		user.update_attributes!(
			updates.reject { |key, value|
				['current_password'].include?(key)
			}
		)
	rescue ActiveRecord::RecordInvalid => e
		render status: 422, json: { error: e.message }
	rescue Exception => e
		render status: 500, json: { error: e.message }
	end

	def validate_password_info(updates, user)
		if updates['current_password'] && updates['password'] && updates['password_confirmation']
			if user.authenticate(updates['current_password'])
				{ valid: true }
			else
				{ valid: false, error: 'Provided current password is invalid.' }
			end
		else
			{ valid: false, error: "Missing password info: #{(['current_password', 'password', 'password_confirmation'] - updates.keys).join(', ')}" }
		end
	end

end
