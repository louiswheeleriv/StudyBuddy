namespace :server do

	task daemon: :environment do
		interval_mins = ENV['DAEMON_INTERVAL_MINS'] ? ENV['DAEMON_INTERVAL_MINS'].to_i : 1
		interval_secs = interval_mins * 60
		puts "Starting server daemon, running every #{interval_mins} minutes"

		loop do
			# Record time and queue job
			last_run = Time.now
			queue_job(last_run)

			# Sleep until next run
			time_next_run = (last_run + interval_secs)
			secs_until_next_run = (time_next_run - Time.now)
			sleep secs_until_next_run
		end
	end

	task daemon_single: :environment do
		queue_job(Time.now)
	end

	def queue_job(time)
		puts "Queueing job for time #{time}"
		Delayed::Job.enqueue(DaemonJob.new(time))
	end

end
