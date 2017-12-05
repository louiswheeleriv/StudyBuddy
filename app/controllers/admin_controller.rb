require './lib/helpers/twilio_helper.rb'
class AdminController < ApplicationController
	before_action :assert_admin_user

	TEST_SMS_MESSAGE = 'This is a test text from the MGH Neurological Clinical Research Institute!'.freeze
	PHASE_DATES_MSG = 'Please provide a start and end date for every phase. Phases must go in order and cannot overlap.'.freeze
	DAYS_OF_WEEK = { 'sun' => 0, 'mon' => 1, 'tue' => 2, 'wed' => 3, 'thu' => 4, 'fri' => 5, 'sat' => 6 }.freeze
	MANAGE_PAGE_LOCKED_FIELDS = ['id', 'created_at', 'updated_at', 'password_digest'].freeze

	def admin
	end

	def signup
		load_studies
	end

	def users
		@study_by_id = Study.all.map { |study| [study.id, study] }.to_h
		@selected_study_id = params['study'] ? params['study'].to_i : nil

		# Collect UserStudy records and their associated Users
		user_studies_by_user_id = UserStudy.where(
			study_id: @selected_study_id ? @selected_study_id : @study_by_id.keys
		).group_by(&:user_id)
		users = User.where(id: user_studies_by_user_id.keys, is_admin: false)

		# Build array of hashes with row data to be rendered
		@rows = users.map do |user|
			user_studies = user_studies_by_user_id[user.id]
			{
				id: user.id,
				participant_numbers: user_studies.map { |user_study|
					[@study_by_id[user_study.study_id].name, user_study.participant_number]
				}.to_h,
				first_name: user.first_name,
				last_name: user.last_name,
				is_active: user_studies.map { |user_study|
					[@study_by_id[user_study.study_id].name, user_study.participant_active]
				}.to_h
			}
		end
	end

	#
	# MANAGE DB PAGES
	#

	def manage_selection
	end

	# Fetch db records for the manage pages
	def manage
		model = params['model']
		@header_record_type_plural = model.name.pluralize
	 	columns = sort_headers(model.columns)
		@headers = columns.map(&:name)
		@rows = model.all.map do |record|
			columns.map do |column|
				{
					value: record.send(column.name.to_sym),
					meta: db_column_meta(column)
				}
			end
		end
		@columns = columns.map do |column|
			db_column_meta(column)
		end
		render 'admin/manage_db'
	end

	# Sort headers to put certain ones at the front/back
	def sort_headers(columns)
		front_headers = ['id']
		back_headers = ['created_at', 'updated_at']
		excluded_headers = []

		sorted = []
		front = []
		back = []
		excluded = []

		columns.each do |column|
			if front_headers.include?(column.name)
				front << column
			elsif back_headers.include?(column.name)
				back << column
			elsif excluded_headers.include?(column.name)
				excluded << column
			else
				sorted << column
			end
		end
		front + sorted + back
	end

	def db_column_meta(column)
		{
			column: column.name,
			type: column.type,
			editable: !MANAGE_PAGE_LOCKED_FIELDS.include?(column.name)
		}
	end

	# Save button clicked on manage db page
	def manage_submit
		errors = {
			creations: process_submitted_creations,
			updates: process_submitted_updates,
			deletions: process_submitted_deletions
		}
		if errors.any? { |type, errs| !errs.empty? }
			render status: 422, json: errors
		end
	rescue Exception => e
		render status: 500, json: { error: e.message }
	end

	# Handle record creations via the manage pages
	def process_submitted_creations
		errors = []
		return errors unless params['model'] && params['creations'] && !params['creations'].empty?
		params['creations'].each do |submitted_creation|
			begin
				params['model'].create!(
					submitted_creation['data'].to_unsafe_h.select { |key, value|
						params['model'].column_names.include?(key)
					}
				)
			rescue Exception => e
				errors << { rowNum: submitted_creation['rowNum'], error: e.message }
			end
		end
		errors
	end

	# Handle record updates via the manage pages
	def process_submitted_updates
		errors = []
		return errors unless params['model'] && params['updates'] && !params['updates'].empty?
		params['updates'].each do |submitted_update|
			begin
				record_id = submitted_update['id'].to_i
				record = params['model'].find_by_id(record_id)
				next unless record
				# Update the record with submitted data
				record.update_attributes!(
					# Only accept fields which are actually on the model
					submitted_update['data'].to_unsafe_h.select { |key, value|
						params['model'].column_names.include?(key)
					}
				)
			rescue Exception => e
				errors << { rowNum: submitted_update['rowNum'], error: e.message }
			end
		end
		errors
	end

	# Handle record deletions via the manage pages
	def process_submitted_deletions
		errors = []
		return errors unless params['model'] && params['deletions'] && !params['deletions'].empty?
		params['deletions'].each do |submitted_deletion|
			begin
				record = params['model'].find_by_id(submitted_deletion['id'])
				next unless record
				record.destroy!
			rescue Exception => e
				errors << { rowNum: submitted_deletion['rowNum'], error: e.message }
			end
		end
		errors
	end

	def load_studies
		@study_message = 'Please select a study.'
		@studies = Study.all
		if @studies.empty?
			@study_message = 'No studies found in database.'
		else
			@study = @studies.first
			@phases = Phase.where(study_id: @study.id)
		end
	end

	def load_study_phases
		if params['study']
			@study = Study.find(params['study'].to_i)
			@phases = Phase.where(study_id: @study.id)
			render status: 200, json: {
				study: @study,
				phase_edit: render_to_string(
					partial: 'shared/user_phase_edit',
					locals: { phases: @phases }
				)
			}
			#render partial: 'shared/user_phase_edit_phases'
		else
			render status: 400, json: {
				'error' => 'No study selected.'
			}
		end
	end

	def test_sms
		puts "Testing SMS with number: #{params['phone']}"
		TwilioHelper.send_text(params['phone'], TEST_SMS_MESSAGE)
		render status: 200, json: {
			'http_code' => 200,
			'message' => 'it worked!',
			'error' => nil
		}.to_json
	rescue Exception => e
		puts "$ADMIN CTRL$ Error in test_sms: #{e.message}\n#{e.backtrace.join("\n")}"
		render status: 500, json: {
			'error' => e.message
		}.to_json
	end

	def signup_submit
		User.transaction do
			u = params['user']
			s = params['schedule']
			pd = params['phase_dates']
			study_id = params['study_id']
			errors = []

			user = User.create(
				is_admin: study_id == 'admin',
				first_name: u['first_name'],
				last_name: u['last_name'],
				username: u['email'],
				email: u['email'],
				password: u['password'],
				password_confirmation: u['password_confirmation'],
				phone: u['phone'],
				timezone: u['timezone']
			)
			user_errors = user.errors.full_messages.uniq
			if !user_errors.empty?
				errors = user_errors.map do |err|
					err_hash(err, '#msg-user')
				end
			end

			# If creating admin, stop here
			if study_id == 'admin'
				if errors.empty?
					# Created admin user, back to admin page
					render js: "window.location = '/admin'" and return
				else
					render status: 400, json: errors and raise ActiveRecord::Rollback
				end
			end

			user_study = UserStudy.create(
				user_id: user.id,
				study_id: study_id,
				participant_active: true,
				participant_number: u['participant_number']
			)

			sched_valid = validate_schedule_data(s) # returns true or an error hash
			if validate_schedule_data(s)
				user_schedules = s.to_unsafe_h.map do |type, time_by_day|
					time_by_day.map do |day, time|
						UserSchedule.create(
							schedule_type: type,
							user_id: user.id,
							time_of_day: time,
							day_of_week: DAYS_OF_WEEK[day]
						)
					end
				end.flatten
			else
				errors << err_hash(
					'Please provide a wake and sleep time for every day of the week.',
					'#msg-schedule'
				)
			end

			phases_valid = validate_phase_dates(pd)
			if phases_valid == true
				user_phases = pd.group_by do |phase_hash|
					phase_hash['phaseId']
				end.map do |phase_id_str, phase_hashes|
					start_dt, end_dt = phase_hashes.partition do |d|
						d['startEndType'] == 'start'
					end.map do |d|
						Date.parse(d.first['date'])
					end
					UserPhase.create(
						user_id: user.id,
						phase_id: phase_id_str.to_i,
						start_date: start_dt,
						end_date: end_dt
					)
				end
			else
				errors << phases_valid
			end

			if errors.empty?
				# Direct to info page about this study
				render js: "window.location = '/admin/signup/study_info?study=#{study_id}'"
			else
				render status: 400, json: errors and raise ActiveRecord::Rollback
			end
		end
	rescue Exception => e
		puts "ERROR in admin#signup_submit: #{e.message}\n#{e.backtrace.join("\n")}"
		render 'signup'
	end

	private

	# Check that posted schedule data meets criteria
	def validate_schedule_data(schedules)
		return schedules['wake'] && schedules['wake'].keys.length == 7 &&
			schedules['sleep'] && schedules['sleep'].keys.length == 7 &&
			DAYS_OF_WEEK.keys.all? { |day|
				schedules['wake'].keys.include?(day) &&
				schedules['sleep'].keys.include?(day)
			}
	end

	# Check that posted phase dates meet criteria
	def validate_phase_dates(phase_dates)
		phase_ids = phase_dates.map { |pd| pd['phaseId'] }.uniq
		phases = phase_ids.map { |pid| Phase.find(pid) }.sort_by { |ph| ph.phase_index ? ph.phase_index : 10000 }
		study = Study.find(phases.first.study_id)

		# Validate that for each phase there's a start and
		# end date, and each date is later than the previous
		prev_dt = nil
		phases.each do |phase|
			dates = phase_dates.select { |pd| pd['phaseId'] == phase.id }

			# Must have two dates for this phase, one start and one end
			return err_hash(PHASE_DATES_MSG, '#msg-phases') unless dates.length == 2 &&
			 	dates.all? { |date|
					date['date']
				} &&
				['start', 'end'].all? { |type|
					dates.map { |d| d['startEndType'] }.include?(type)
				}

			# start must be after prev_dt, end must be after start
			start_dt, end_dt = dates.partition do |d|
				d['startEndType'] == 'start'
			end.map do |d|
				Date.parse(d.first['date'])
			end
			return err_hash(PHASE_DATES_MSG, '#msg-phases') unless (
					prev_dt.nil? ||
					start_dt > prev_dt
				) &&
				end_dt > start_dt
			prev_dt = end_dt
		end
		true
	end

	def err_hash(error, location)
		{
			error: error,
			location: location
		}
	end

	def assert_admin_user
    redirect_to(root_url) unless is_admin?
  end

end
