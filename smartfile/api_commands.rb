require 'json'

class APICommands
	def initialize(caller)
		@API = caller
	end
    
	def GetFileData(filename, path=nil)
		filePath = "#{path}/#{filename}"
		result = @API.doAPICall('GET', '/path/data' + filePath, true)
		return result
	end

	def SendToSmartFile(filename, path="", fileMIMEType)
		filePath = "#{path}/"
		puts "Uploading #{filename}"
		result = @API.doMultipartAPICall('/path/data/' + filePath, filename, fileMIMEType, true)
		return result
	end

	def MakeDirectory(directoryName, path=nil)
		params = Hash.new
		finalPath = ""
		finalPath = "/" + path if !path.nil?
		finalPath += "/" + directoryName
		params = "path=#{finalPath}"
		result = @API.doAPICall("POST", "/path/oper/mkdir/", true, params) 
		return result
	end

	def GetAccountNames()
		result = @API.doAPICall("GET", "/path/info/allurmailz/?children=on", true)
		folderData = JSON.parse(result)
		accountList = Array.new
		folderData["children"].each do |folder|
			accountList << folder["name"]
		end 
		return accountList
	end

	def GetMailFolders(accountName)
		result = @API.doAPICall("GET", "/path/info/allurmailz/#{accountName}/?children=on", true)
		folderData = JSON.parse(result)
		folderList = Array.new
		folderData["children"].each do |folder|
			if folder["name"] != "mailstats.json" && folder["isdir"]
				folderList << folder["name"]
			end
		end 
		return folderList
	end

	def GetMessagesFromFolder(accountName, folder)
		result = @API.doAPICall("GET", "/path/info/allurmailz/#{accountName}/#{folder}/?children=on", true)
		folderData = JSON.parse(result)
		emailList = Array.new
		if !folderData["children"].nil?
			folderData["children"].each do |message|
				emailData = GetFileData(message["name"], "/allurmailz/#{accountName}/#{folder}")
				email = Email.CreateFromJSON(emailData)
		        emailList << email.to_hash if !email.nil?
				puts "Email had an error!" if email.nil?
			end 
			return emailList.to_json
		end
	end
	
	# IMPORTANT: Send the hashId from the email!
	def GetEmail(accountName, folder, emailID)
		emailJSON = GetFileData(emailID + ".json", "/allurmailz/#{accountName}/#{folder}")
		return Email.CreateFromJSON(emailJSON)		
	end
	
	def GetWordStatistics(accountName)
		begin
			stats = GetFileData("mailstats.json", "/allurmailz/#{accountName}")
			#return JSON.parse(stats)
			return stats
		rescue
			return
		end
	end
end

#c = APICommands.new
#fileData = c.GetFileData('test1.txt')
#puts "Read from API: #{fileData}"
#c.SendToSmartFile('test1.txt', nil, "text/plain")
#puts "Making Directory"
#c.MakeDirectory("test", "allurmailz")
