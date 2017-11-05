class StudyController < ApplicationController

	def study
		@study = Study.find(params['study_id'].to_i)
	end

end
