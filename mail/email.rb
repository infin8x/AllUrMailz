require 'json'

class Email
	attr_accessor :fromName, :fromEmail, :to, :subject, :body, :id, :timeSent

	def initialize
		@fromName = "Unknown!"
		@fromEmail = "Unknown!"
		@to = "Unknown!"
		@subject = "Unknown!"
		@body = "Unknown!"
		@timeSent = "Unknown!"
		@id = "Unknown!"
	end

	def to_json
		daHash = {:fromName => @fromName, :fromEmail => @fromEmail, :to => @to, :subject => @subject, :body => @body, :timeSent => @timeSent, :id => @id}
		return daHash.to_json
	end

	def self.CreateFromJSON(messageJSON)
		messageData = JSON.parse(messageJSON)
		mail = Email.new
		mail.fromName = messageData[:fromName]
		mail.fromEmail = messageData[:fromEmail]
		mail.to = messageData[:to]
		mail.subject = messageData[:subject]
		mail.body = messageData[:body]
		mail.timeSent = messageData[:timeSent]
		mail.id = messageData[:id]
	end

	def toString
		return "#{@from} - #{@subject} - #{@timeSent}"
	end

end
