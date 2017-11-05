class TwilioHelper

	attr_reader :message_by_recipient

	def initialize(message_by_recipient)
		@message_by_recipient = message_by_recipient
	end

	def self.send_texts(message_by_recipient)
		new(message_by_recipient).send_texts
	end

	def self.send_text(recipient, message)
		new({ recipient => message }).send_texts
	end

	def send_texts
		message_by_recipient.each do |recipient, message|
			send_text(recipient, message)
		end
	end

	def send_text(recipient, message)
		RestClient::Request.execute(
			method: :post,
			url: twilio_url,
			payload: {
				'To' => recipient,
				'From' => twilio_sender_number,
				'Body' => message
			},
			user: account_sid,
			password: twilio_token
		)
	end

	def account_sid
		@account_sid ||= ENV.fetch('TWILIO_ACCOUNT_SID')
	end

	def twilio_token
		@twilio_token ||= ENV.fetch('TWILIO_TOKEN')
	end

	def twilio_sender_number
		@twilio_sender_number ||= ENV.fetch('TWILIO_PHONE_NUMBER')
	end

	def twilio_url
		@twilio_url ||= "https://api.twilio.com/2010-04-01/Accounts/#{account_sid}/Messages.json"
	end

end
