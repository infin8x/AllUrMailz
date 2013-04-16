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
		session[:caller] ||= APICaller.new
    end
	
	def root_url
		request.url.match(/(^.*\/{2}[^\/]*)/)[1]
	end
	
	get "/request" do
		token, secret = session[:caller].oAuthGetRequestToken(root_url)
        session[:oauth][:request_token] = token
        session[:oauth][:request_token_secret] = secret
        redirect 'https://app.smartfile.com/oauth/authorize?oauth_token=' + CGI::escape(token)
    end
	
    get '/auth' do
		token, secret = session[:caller].oAuthGetAccessToken(params['verifier'])
        session[:oauth][:access_token] = token
        session[:oauth][:access_token_secret] = secret
        redirect '/whoami'
    end
	
    get '/whoami' do
        response = JSON.parse(session[:caller].doAPICall('GET', '/whoami/', oauth = true))
        session[:userinfo][:username] = response['user']['name']
        session[:userinfo][:signedin] = true
        redirect '/'
    end

    get '/signout' do 
        session[:oauth] = {}  
        session[:userinfo] = {}
        redirect '/'
    end

    get '/' do
        haml :index
    end

    get '/settings' do
        haml :settings
    end

    post '/settings' do
        puts params
        redirect '/settings'
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
end
