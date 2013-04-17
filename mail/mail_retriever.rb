require 'viewpoint'
require 'digest/sha1'
#require './email'

include Viewpoint::EWS


class MailRetriever
	attr_accessor :user, :password, :server

	def initialize(user=nil, passwd=nil, server=nil)

		@API = APICommands.new
		@user = user
		@password = passwd
		@server = server
	end

	def getFolders
		if(@user.nil? || @password.nil? || @server.nil?)
			throw "Not all connection information is set!"
		end
		cli = Viewpoint::EWSClient.new(@server, @user, @password)
		folders = cli.folders traversal: :deep
		jsonArray = Array.new
		folders.each do |folder|
			thisOne = Hash.new
			thisOne[:folder] = folder.name
			jsonArray << thisOne
		end
		return jsonArray.to_json
	end

	# Method needs work with folders to get functioning properly.
	def retrieveMailFromFolders(folderNames)
		begin
			cli = Viewpoint::EWSClient.new(@server, @user, @password)
		
			folders = Array.new
			folderNames.each do |folderName|
				folders << cli.get_folder_by_name(folderName)
			end
			
			serverHost = URI.parse(@server).host
			FileUtils.mkdir("tmp") if !File.directory?("tmp")

			folders.each do |folder|
				folderName = URI.encode(folder.name)
				@API.MakeDirectory(folderName, "allurmailz/#{@user}@#{serverHost}")
				items = folder.items

				items.each do |item|
					next if !item.kind_of?(Viewpoint::EWS::Types::Message)
					
					message = item.get_all_properties!
					email = Email.new
					email.fromName = item.sender.name
					email.fromEmail = item.sender.email_address
					email.timeSent = item.date_time_sent
					email.subject = item.subject
					email.id = URI.encode(item.id)
					email.hashId = Digest::SHA1.hexdigest(email.id).to_s

					begin
						email.body = message[:body][:text]
						email.to = message[:to_recipients][:elems][0][:mailbox][:elems][0][:name][:text]
					rescue		
						puts "Whoops!"
					end

					fileName = email.hashId + ".json"
					File.open(fileName, "w") { |file| file.write(email.to_json) }
					path = "allurmailz/#{@user}@#{serverHost}/#{folderName}"
					@API.SendToSmartFile(fileName, path, "application/json")
					File.delete(fileName)
				end
			end
			return true
		rescue Exception => e
			puts e
			return false
		end
	end

	def randomString
		return (0...8).map{(65+rand(26)).chr}.join
	end
end
