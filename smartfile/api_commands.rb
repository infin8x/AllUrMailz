require 'json'
require_relative 'api_caller.rb'

def GetFileData(filename, path=nil)
	api = APICaller.new
	filePath = "#{path}/#{filename}"
	result = api.doAPICall('GET', '/path/data' + filePath)
	return result
end

def SaveFile(filename, path=nil, fileData, fileMIMEType)
	api = APICaller.new
	filePath = "#{path}/#{filename}"
	result = api.doMultipartAPICall('/path/data' + filePath, filename, fileData, fileMIMEType)
	return result
end

fileData = GetFileData('test.txt')
SaveFile('test2.txt', nil, fileData, "text/plain")