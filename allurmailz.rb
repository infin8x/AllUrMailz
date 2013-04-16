# allurmailz.rb
require 'sinatra'
require 'thin'
require 'haml'
require 'net/https'
require 'json'
require './smartfile/api_caller.rb'

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

    end

    post '/selectFolders' do

    end

    get '/:sname/:fname' do

    end

    get '/:sname/:fname/:iid' do

    end
end
