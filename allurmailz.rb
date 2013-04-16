# allurmailz.rb
require 'sinatra'
require 'thin'
require 'haml'
require 'net/https'
require 'json'
require './smartfile/api_commands'
require './smartfile/api_caller'
require './mail/mail_retriever'
require './mail/email'

USERNAME = 'kennedle'
PASSWORD = 'TmV2ZXJzYXlkaWUw'
SERVER = 'https://exchange.rose-hulman.edu/ews/exchange.asmx'

class AllUrMailz < Sinatra::Base
    before do
        session[:oauth] ||= {}
        session[:userinfo] ||= {}
        @consumer_key = 'V58Lo7BySs01zaXBOr1qhZHMMQIXSL'
        @consumer_secret = 'SMb4Z96sC1U1Rbk8To4WKaAyGqMw8L'

        session[:api_caller] = APICaller.new
    end

    get '/auth' do
        http = Net::HTTP.new('app.smartfile.com',443)
        http.use_ssl = true

        path = '/oauth/access_token/'
        args = 'oauth_version=1.0&oauth_nonce=' + nonce.to_s + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_consumer_key=' + @consumer_key + '&oauth_token=' + session[:oauth][:request_token] + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%26' + session[:oauth][:request_token_secret] + '&oauth_verifier=' + params['verifier']

        res = http.post(path,args)
        split = res.body.split(/=|&/)

        session[:oauth][:access_token] = split[3]
        session[:oauth][:access_token_secret] = split[1]
        redirect '/whoami'
    end

    def nonce
        rand(10 ** 30).to_s.rjust(30,'0')
    end

    get "/request" do
        http = Net::HTTP.new('app.smartfile.com', 443)
        http.use_ssl = true

        path = '/oauth/request_token/'
        args = 'oauth_version=1.0&oauth_nonce=' + nonce.to_s + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_consumer_key=' + @consumer_key + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%2526' + '&oauth_callback=' + CGI::escape('http://arapahoebasin.reshall.rose-hulman.edu/auth')  

        res = http.post(path, args)
        split = res.body.split(/=|&/)

        session[:oauth][:request_token] = split[3]
        session[:oauth][:request_token_secret] = split[1]

        redirect 'https://app.smartfile.com/oauth/authorize?oauth_token=' + CGI::escape(split[3])
    end

    get '/signout' do 
        session[:oauth] = {}  
        session[:userinfo] = {}
        redirect '/'
    end

    get '/' do
        haml :index
    end

    get '/item' do
        haml :item
    end

    get '/settings' do
        haml :settings
    end

    post '/settings' do
        puts params
        redirect '/settings'
    end

    get '/connectToServer' do
        
    end

    get '/selectFolders' do
		retriever = MailRetriever.new(USERNAME, Base64.decode64(PASSWORD), SERVER)
		folders = retriever.getFolders
		@folderNames = Array.new
		folders.each do |folder|
			@folderNames << folder.name
		end
		@folderNames.to_s
    end

    post '/selectFolders' do
		retriever = MailRetriever.new(USERNAME, Base64.decode64(PASSWORD), SERVER)
		result = retriever.retrieveMailFromFolders(params[:folders])
		"Done"
    end

    get '/read/:sname/:fname' do
		c = APICommands.new
		# Debug
		puts params[:sname]
		puts params[:fname]
		emails = c.GetMessagesFromFolder(params[:sname], URI.encode(params[:fname]))
		# kennedle@exchange.rose-hulman.edu/Class%20Information
		
		#Sample Stuff, to show it is working
		output = ""
		emails.each do |email|
			output += "#{email.to_s}\n"
		end
		output
    end

    get '/read/:sname/:fname/:iid' do
		c = APICommands.new
		@email = c.GetEmail(params[:sname], URI.encode(params[:fname]), params[:iid])
		@email.body
    end

    get '/whoami' do
        uri = URI.parse(URI.encode('https://app.smartfile.com/api/2/whoami/?format=json&oauth_consumer_key=' + @consumer_key + '&oauth_token=' + session[:oauth][:access_token] + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%26' + session[:oauth][:access_token_secret] + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_nonce=' + nonce.to_s + '&oauth_version=1.0'))
        puts uri.host
        puts uri.port
        puts uri.request_uri
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Get.new(uri.request_uri)
        http.use_ssl = true

        res = http.request(req)
        response = JSON.parse(res.body)
        session[:userinfo][:username] = response['user']['name']
        session[:userinfo][:signedin] = true
        redirect '/'
    end
end
