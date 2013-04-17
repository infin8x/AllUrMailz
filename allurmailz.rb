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
	configure do
		enable :sessions
		set :session_secret, ENV['SESSION_SECRET'] ||= 'my super super secret session secret'
	end
	
    before do
        session[:oauth] ||= {}
        session[:userinfo] ||= {}
		session[:exchange] ||= {}
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
        redirect '/settings'
    end
	
	get '/getEmail' do
		haml :getEmail
	end
	
	post '/getEmail' do
        puts params
		session[:exchange][:server] = params['server']
		session[:exchange][:username] = params['username']
		session[:exchange][:password] = params['password']
		redirect '/selectFolders'
	end

    get '/selectFolders' do
		session[:retriever] = MailRetriever.new(session[:exchange][:username], session[:exchange][:password], session[:exchange][:server], session[:caller])
		folders = session[:retriever].getFolders
		haml :selectFolders, :locals => {:folders => folders}
    end

    post '/selectFolders' do
        request.body.rewind
        data =  request.body.read
        converted = eval(data)
		result = session[:retriever].retrieveMailFromFolders(converted)
    end

    get '/data/:sname/:fname' do
        headers \
            "Content-Type" => "application/json"
        c = APICommands.new(session[:caller])
		toReturn = c.GetMessagesFromFolder(params[:sname], URI.encode(params[:fname]))
        puts toReturn
        toReturn
        # kennedle@exchange.rose-hulman.edu/Class%20Information
    end
    
    get '/read/:sname/:fname' do
		haml :selectEmails, :locals => {:currentFolder => params[:fname], :dataUrl => root_url + "/data/#{params[:sname]}/#{params[:fname]}", :emailBaseUrl => root_url + "/read/#{params[:sname]}/#{params[:fname]}/"}
    end

    get '/read/:sname/:fname/:iid' do
		c = APICommands.new(session[:caller])
		@email = c.GetEmail(params[:sname], URI.encode(params[:fname]), params[:iid])
		@email.body
    end
end
