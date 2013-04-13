require 'viewpoint'
require './email'

include Viewpoint::EWS


class MailRetriever
	attr_accessor :user, :password, :server

	def initialize(user=nil, passwd=nil, server=nil)
		@user = user
		@password = passwd
		@server = server
	end

	def getFolders
		if(@user.nil? || @password.nil? || @server.nil?)
			throw "Not all connection information is set!"
		end
		cli = Viewpoint::EWSClient.new(@server, @user, @password)

		return cli.folders traversal: :deep
	end

	def retrieveAllMail
		#folders = getFolders
		
		folders = Array.new
		cli = Viewpoint::EWSClient.new(@server, @user, @password)
		folders << cli.get_folder(:inbox)
		folders << cli.get_folder_by_name("Bruce")
		
		greatMailHash = Hash.new
		folders.each do |folder|
			items = folder.items
			mailList = Array.new
			items.each do |item|
				next if !item.kind_of?(Viewpoint::EWS::Types::Message)
				
				message = item.get_all_properties!
				email = Email.new
				email.fromName = item.sender.name
				email.fromEmail = item.sender.email_address
				email.timeSent = item.date_time_sent
				email.subject = item.subject
				email.id = item.id
				begin
					email.body = message[:body][:text]
					email.to = message[:to_recipients][:elems][0][:mailbox][:elems][0][:name][:text]
				rescue		
					puts "Whoops!"
				end
				mailList << email
			end
			greatMailHash[folder.name] = mailList
		end
		return greatMailHash
	end

	def saveMailHash(mailHash)
		FileUtils.mkdir("allurmailz") if !File.directory?("allurmailz")
		mailHash.each do |folder, messages|
			dirName = "allurmailz/#{folder}"
			FileUtils.mkdir(dirName) if !File.directory?(dirName)
			messages.each do |message|
				File.open(dirName + "/" + message.id.gsub("/",""), "w") { |file| file.write(message.to_json) }
			end
		end
	end
end
