class DaemonJob

	attr_reader :run_time

	def initialize(run_time)
		@run_time = run_time.utc
	end

	def perform
		puts "Starting job for time #{run_time}"
		user_phases.each do |user_phase|
			data = data_for_user_phase(user_phase)
			data[:questions].each do |question|
				next unless ask_question?(question, data)

			end
		end
	end

	def data_for_user_phase(user_phase)
		user = user_by_id[user_phase.user_id]
		{
			user: user,
			questions: questions_by_phase_id[user_phase.phase_id],
			user_data_by_question_id: user_data_by_question_id_by_user_id[user.id],
			user_schedules: user_schedules_by_user_id[user.id]
		}
	end

	def ask_question?(question, data)
		ask_question_today?(question, data) &&
		ask_question_now?(question, data)
	end

	def ask_question_today?(question, data)
		last_user_datum = last_user_datum_for_question(question, data)
		[1, nil].include?(question.every_n_days) ||
			last_user_datum.nil? ||
			last_user_datum.created_at.to_date == run_time.to_date ||
			(run_time.to_date - last_user_datum.created_at.to_date) >= question.every_n_days
	end

	def ask_question_now?(question, data)
		ws_data = wake_sleep_data_utc(data)

		# Check if within wake/sleep hours
		return false unless ws_data[:wake][:hour] <= run_time.hour &&
			ws_data[:wake][:minute] <= run_time.min &&
			ws_data[:sleep][:hour] >= run_time.hour &&
			ws_data[:sleep][:minute] >= run_time.min

		# Check if question needs to be asked now
		last_user_datum = last_user_datum_for_question(question, data)
		last_user_datum.nil? ||
			last_user_datum.created_at.to_date < run_time.to_date ||
			(run_time.hour - last_user_datum.created_at.hour) >= question.hour_offset
	end

	def last_user_datum_for_question(question, data)
		return nil unless data[:user_data_by_question_id] && question
		data[:user_data_by_question_id][question.id].last
	end

	# Build hash of wake/sleep times for user as ints in utc
	def wake_sleep_data_utc(data)
		tz_offset = user_tz_offset(data[:user])
		wake_hr, wake_min = data[:user_schedules][:wake].time_of_day.split(':')
		sleep_hr, sleep_min = data[:user_schedules][:sleep].time_of_day.split(':')
		{
			wake: { hour: wake_hr.to_i - tz_offset, minute: wake_min.to_i },
			sleep: { hour: sleep_hr.to_i - tz_offset, minute: sleep_min.to_i }
		}
	end

	# Returns int of timezone offset
	def user_tz_offset(user)
		JSON.parse(user.timezone)['gmtOffset'].to_i
	end

	def study_by_id
		@study_by_id ||= Study.where(
			'start_date <= ? and end_date >= ?',
			run_time,
			run_time
		).map do |study|
			[study.id, study]
		end.to_h
	end

	def user_studies
		@user_studies ||= UserStudy.where(
			study_id: study_by_id.keys,
			participant_active: true
		)
	end

	def phase_by_id
		@phase_by_id ||= Phase.where(
			study_id: study_by_id.keys
		).map do |phase|
			[phase.id, phase]
		end.to_h
	end

	def user_phases
		@user_phases ||= UserPhase.where(
			phase_id: phase_by_id.keys
		).where(
			'start_date <= ? and end_date >= ?',
			run_time,
			run_time
		)
	end

	def user_by_id
		@user_by_id ||= User.where(
			id: user_phases.map { |up| up.user_id }.uniq
		).map do |user|
			[user.id, user]
		end.to_h
	end

	def user_schedules_by_user_id
		@user_schedules_by_user_id ||= UserSchedule.where(
			user_id: user_by_id.keys,
			day_of_week: run_time.wday
		).group_by(&:user_id).map do |user_id, user_schedules|
			[user_id, {
				wake: user_schedules.find { |us| us.schedule_type == 'wake' },
				sleep: user_schedules.find { |us| us.schedule_type == 'sleep' }
			}]
		end.to_h
	end

	def questions_by_phase_id
		@questions_by_phase_id ||= Question.where(
			phase_id: phase_by_id.keys
		).group_by(&:phase_id)
	end

	def user_data_by_question_id_by_user_id
		@user_data_by_question_id_by_user_id ||= UserDatum.where(
			user_id: user_by_id.keys,
			question_id: questions_by_phase_id.values.flatten.map { |q| q.id }.uniq
		).group_by(&:user_id).map do |user_id, user_data|
			[
				user_id,
				user_data.group_by(&:question_id).map { |q_id, user_data|
					[q_id, user_data.sort_by(&:created_at)]
				}.to_h
			]
		end.to_h
	end

end
