class DashboardController < ApplicationController
	before_action :assert_logged_in

	def assert_logged_in
		redirect_to(root_url) unless logged_in?
	end

	def dashboard
		if is_admin?
			redirect_to('/admin')
		else
			# TODO: Also restrict to questions asked today
			@questions = UserDatum.where(
				user_id: current_user.id,
				answered_at: nil
			).map do |user_datum|
				{
					user_datum_id: user_datum.id,
					question_id: user_datum.question_id,
					question_text: user_datum.question.question_text,
					answer_type: parse_answer_type(user_datum.question)
				}
			end.to_json
		end
	end

	def parse_answer_type(question)
		if question.answer_type.include?('number')
			if question.answer_type.include?(':')
				min, max = question.answer_type.split(':').last.split('..')
				{ type: 'number', range: { min: min, max: max }}
			else
				{ type: 'number' }
			end
		elsif question.answer_type.include?('enum')
			options = question.answer_type.split(':').last.split('|')
			{ type: 'enum', options: options }
		else
			{ type: question.answer_type }
		end
	end

end
