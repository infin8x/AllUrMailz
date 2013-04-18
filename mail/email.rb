require 'json'

class Email
	attr_accessor :fromName, :fromEmail, :to, :subject, :body, :id, :timeSent, :hashId

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
		daHash = {:fromName => @fromName, :fromEmail => @fromEmail, :to => @to, :subject => @subject, :body => @body, :timeSent => @timeSent, :id => @id, :hashId => @hashId}
		return daHash.to_json
	end
    
	def to_hash
		return {:fromName => @fromName, :fromEmail => @fromEmail, :to => @to, :subject => @subject, :timeSent => @timeSent, :hashId => @hashId}
	end

	def self.CreateFromJSON(messageJSON)
		messageData = JSON.parse(messageJSON)
		mail = Email.new
		mail.fromName = messageData["fromName"]
		mail.fromEmail = messageData["fromEmail"]
		mail.to = messageData["to"]
		mail.subject = messageData["subject"]
		mail.body = messageData["body"]
		mail.timeSent = messageData["timeSent"]
		mail.id = messageData["id"]
		mail.hashId = messageData["hashId"]
		return mail
	end

	def to_s
		return "#{@fromName} - #{@subject} - #{@timeSent}"
	end
end
