require 'json'
#require './api_caller'

class APICommands
	def GetFileData(filename, path=nil)
		api = APICaller.new
		filePath = "#{path}/#{filename}"
		result = api.doAPICall('GET', '/path/data' + filePath)
		return result
	end

	def SendToSmartFile(filename, path="", fileMIMEType)
		api = APICaller.new
		filePath = "#{path}/"
		puts "Uploading #{filename}"
		result = api.doMultipartAPICall('/path/data/' + filePath, filename, fileMIMEType)
		return result
	end

	def MakeDirectory(directoryName, path=nil)
		api = APICaller.new
		params = Hash.new
		finalPath = ""
		finalPath = "/" + path if !path.nil?
		finalPath += "/" + directoryName
		params = "path=#{finalPath}"
		result = api.doAPICall("POST", "/path/oper/mkdir/", params) 
		return result
	end

	def GetAccountNames()
		api = APICaller.new
		result = api.doAPICall("GET", "/path/info/allurmailz/?children=on")
		folderData = JSON.parse(result)
		accountList = Array.new
		folderData["children"].each do |folder|
			accountList << folder["name"]
		end 
		return accountList
	end

	def GetMailFolders(accountName)
		api = APICaller.new
		result = api.doAPICall("GET", "/path/info/allurmailz/#{accountName}/?children=on")
		folderData = JSON.parse(result)
		folderList = Array.new
		folderData["children"].each do |folder|
			folderList << folder["name"]
		end 
		return folderList
	end

	def GetMessagesFromFolder(accountName, folder)
		api = APICaller.new
		result = api.doAPICall("GET", "/path/info/allurmailz/#{accountName}/#{folder}/?children=on")
		folderData = JSON.parse(result)
		emailList = Array.new
		folderData["children"].each do |message|
			emailData = GetFileData(message["name"], "/allurmailz/#{accountName}/#{folder}")
			emailList << Email.CreateFromJSON(emailData)
		end 
		return emailList
	end
end

#c = APICommands.new
#fileData = c.GetFileData('test1.txt')
#puts "Read from API: #{fileData}"
#c.SendToSmartFile('test1.txt', nil, "text/plain")
#puts "Making Directory"
#c.MakeDirectory("test", "allurmailz")
