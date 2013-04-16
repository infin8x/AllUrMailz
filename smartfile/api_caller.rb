require 'net/https'
require 'json'
require 'net/http/post/multipart' #http://github.com/nicksieger/multipart-post

class APICaller
	require_relative 'auth.rb'

	API_VERSION = "2"
	API_SERVER = "app.smartfile.com"
	API_BASE_URL = "/api/#{API_VERSION}"

	def doAPICall(method, path, parameters=nil) 
		http = Net::HTTP.new(API_SERVER, 443)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		req = getHTTPRequestForVerb(method, API_BASE_URL + path)

		if !parameters.nil?
			post_body = []
			post_body << parameters
			req.body = post_body.join
		end

		#print API_SERVER + API_BASE_URL + path + "\n"

		
		resp, data = http.request(req)
		if resp.code == "200"
			return resp.body
		else
			puts "#{method} - #{path}"
			puts resp.body if !resp.body.nil?

			raise 'Network Error ' + resp.code
		end
	end
	
	def doMultipartAPICall(path, fileName, fileMIMEType)
		puts "Starting multi-part post" 
		http = Net::HTTP.new(API_SERVER, 443)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		actualFileName = fileName.split("/").last
		puts "The actual file name is #{actualFileName}"
		File.open(fileName) do |file|
			req = Net::HTTP::Post::Multipart.new API_BASE_URL + path, "file" => UploadIO.new(file, fileMIMEType, actualFileName)

			# For use until we get OAUTH working. Great for testing!
			# Be sure to keep auth.rb private.
			req.basic_auth UNAME, PASSWD
			puts "Calling #{API_BASE_URL + path}"
			#req.each_header {|key,value| puts "#{key} = #{value}" }
			resp, data = http.request(req)
			if resp.code == "200"
				return resp.body
			else
				puts "Response Headers:"
				resp.header.each_header {|key,value| puts "#{key} = #{value}" }
				puts "Response Body:"
				puts resp.body if !resp.body.nil?
				raise 'Network Error ' + resp.code
			end
		end
	end

	def getHTTPRequestForVerb(verb, path)
        path += '?format=json&oauth_consumer_key=' + @consumer_key + '&oauth_token=' + session[:oauth][:access_token] + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%26' + session[:oauth][:access_token_secret] + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_nonce=' + nonce.to_s + '&oauth_version=1.0' 

		req = Net::HTTP::Get.new(path) if verb.upcase == "GET"
		req = Net::HTTP::Post.new(path) if verb.upcase == "POST"
		req = Net::HTTP::Put.new(path) if verb.upcase == "PUT"
		req = Net::HTTP::Delete.new(path) if verb.upcase == "DELETE"
		raise "Invalid HTTP Verb - \'#{verb}\'" if req.nil?
		return req
	end

end
