require 'net/https'
require 'json'

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

		# For use until we get OAUTH working. Great for testing!
		# Be sure to keep auth.rb private.
		req.basic_auth UNAME, PASSWD

		if !parameters.nil?
			post_body = []
			post_body << params
			req.body = post_body.join
		end

		resp, data = http.request(req)
		if resp.code == "200"
			return resp.body
		else
			return 'Error ' + resp.code
		end
	end

	def getHTTPRequestForVerb(verb, path)
		req = Net::HTTP::Get.new(path) if verb.upcase == "GET"
		req = Net::HTTP::Post.new(path) if verb.upcase == "POST"
		req = Net::HTTP::Put.new(path) if verb.upcase == "PUT"
		req = Net::HTTP::Delete.new(path) if verb.upcase == "DELETE"
		raise NetworkException.new("Invalid HTTP Verb - \'#{verb}\'") if req.nil?
		return req
	end

end

api = APICaller.new
print api.doAPICall('GET', '/path/info/') + "\n"
