require 'viewpoint'
require 'digest/sha1'
#require './email'

include Viewpoint::EWS


class MailRetriever
	attr_accessor :user, :password, :server, :caller

	def initialize(user=nil, passwd=nil, server=nil, caller = nil)
		@API = APICommands.new(caller)
		@user = user
		@password = passwd
		@server = server
		@stats = Stats.new
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

	def retrieveMailFromFolders(folderNames)		
		cli = Viewpoint::EWSClient.new(@server, @user, @password)
	
		folders = Array.new
		folderNames.each do |folderName|
			folders << cli.get_folder_by_name(URI.decode(folderName))
		end
		
		serverHost = URI.parse(@server).host
		FileUtils.mkdir("tmp") if !File.directory?("tmp")
		errors = 0
		folders.each do |folder|
			begin
				folderName = URI.encode(folder.name)
				@API.MakeDirectory(folderName, "allurmailz/#{@user}@#{serverHost}")
				items = folder.items
				
				items.each do |item|
					next if !item.kind_of?(Viewpoint::EWS::Types::Message)
					begin
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
				
						@stats.parseBlock(email.body)

						fileName = email.hashId + ".json"
						File.open(fileName, "w") { |file| file.write(email.to_json) }
						path = "allurmailz/#{@user}@#{serverHost}/#{folderName}"
						@API.SendToSmartFile(fileName, path, "application/json")
						File.delete(fileName)
					rescue Exception => e
						puts e
						errors = errors + 1
					end
				end
			rescue Exception => e
				puts e
				puts "Folder Error!"
			end
		end
		
		begin
			File.open("mailstats.json", "w") { |file| file.write(@stats.to_json) }
			path = "allurmailz/#{@user}@#{serverHost}"
			@API.SendToSmartFile("mailstats.json", path, "application/json")
			File.delete("mailstats.json")
		rescue Exception => e
			puts e
		end	
		puts "Error Count: " + errors.to_s
		return true
	end

	def randomString
		return (0...8).map{(65+rand(26)).chr}.join
	end
end
