require 'net/https'
require 'json'
require 'net/http/post/multipart' #http://github.com/nicksieger/multipart-post
#require_relative './auth.rb'


class APICaller
	CONSUMER_KEY = 'usweLaXXHfAl9gbFQFKGEuaxydaGpX'
    CONSUMER_SECRET = 'nxgwtuSNd39b9H0GDVIYDKmDxjquSJ'

	API_VERSION = "2"
	API_SERVER = "app.smartfile.com"
	API_BASE_URL = "/api/#{API_VERSION}"

	def oAuthNonce
        rand(10 ** 30).to_s.rjust(30,'0')
    end
	
	def oAuthGetRequestToken(callback)
		http = Net::HTTP.new('app.smartfile.com', 443)
        http.use_ssl = true

        path = '/oauth/request_token/'
        args = 'oauth_version=1.0&oauth_nonce=' + oAuthNonce.to_s + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_consumer_key=' + CONSUMER_KEY + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + CONSUMER_SECRET + '%2526' + '&oauth_callback=' + CGI::escape(callback + '/auth')  

        res = http.post(path, args)
        split = res.body.split(/=|&/)
		@request_token = split[3]
		@request_token_secret = split[1]
		return split[3], split[1]
	end
	
	def oAuthGetAccessToken(verifier)
	    http = Net::HTTP.new('app.smartfile.com',443)
        http.use_ssl = true
        path = '/oauth/access_token/'
        args = 'oauth_version=1.0&oauth_nonce=' + oAuthNonce.to_s + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_consumer_key=' + CONSUMER_KEY + '&oauth_token=' + @request_token + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + CONSUMER_SECRET + '%26' + @request_token_secret + '&oauth_verifier=' + verifier

        res = http.post(path,args)
        split = res.body.split(/=|&/)
		@access_token = split[3]
		@access_token_secret = split[1]
		return split[3], split[1]
	end
    
    def oAuthHeader
        return 'OAuth oauth_consumer_key="' + CONSUMER_KEY + '",oauth_token="' + @access_token +  '",oauth_signature_method="PLAINTEXT",oauth_signature="' + CONSUMER_SECRET + '%26' + @access_token_secret + '",oauth_timestamp="' + Time.now.to_i.to_s + '",oauth_nonce="' + oAuthNonce.to_s + '",oauth_version="1.0"'
    end
	
	def doAPICall(method, path, oauth = false, parameters=nil) 
		http = Net::HTTP.new(API_SERVER, 443)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		req = getHTTPRequestForVerb(method, API_BASE_URL + path, oauth)
		
		if !parameters.nil?
			post_body = []
			post_body << parameters
			req.body = post_body.join
		end

		resp, data = http.request(req)
		if resp.code == "200"
			return resp.body
		else
			puts "#{method} - #{path}"
			puts resp.body if !resp.body.nil?

			raise 'Network Error ' + resp.code
		end
	end
	
	def doMultipartAPICall(path, fileName, fileMIMEType, oauth = false)
		puts "Starting multi-part post" 
		http = Net::HTTP.new(API_SERVER, 443)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		actualFileName = fileName.split("/").last
		puts "The actual file name is #{actualFileName}"
		File.open(fileName) do |file|
			req = Net::HTTP::Post::Multipart.new API_BASE_URL + path, "file" => UploadIO.new(file, fileMIMEType, actualFileName)

            req['Authorization'] = oAuthHeader if oauth
            req.basic_auth UNAME, PASSWD if !oauth
			
			#puts "Calling #{API_BASE_URL + path}"
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

	def getHTTPRequestForVerb(verb, path, oauth = false)
		req = Net::HTTP::Get.new(path) if verb.upcase == "GET"
		req = Net::HTTP::Post.new(path) if verb.upcase == "POST"
		req = Net::HTTP::Put.new(path) if verb.upcase == "PUT"
		req = Net::HTTP::Delete.new(path) if verb.upcase == "DELETE"
		raise "Invalid HTTP Verb - \'#{verb}\'" if req.nil?
		
        req['Authorization'] = oAuthHeader if oauth
        req.basic_auth UNAME, PASSWD if !oauth
		return req
	end
end
