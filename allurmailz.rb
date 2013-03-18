# allurmailz.rb
require 'sinatra'
require 'thin'
require 'haml'
require 'oauth'
require 'oauth/consumer'

enable :sessons

before do
    session[:oauth] ||= {}
    consumer_key = 'K56Fxx6NUQmDdlVm9bSIBQKmKGtuwb'
    consumer_secret = 'wMO9VRrQG6VUS8hToYC9BkRMWV6fFE'
    
    @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "https://app.smartfile.com", :oauth_signature_method => "PLAINTEXT"})

#    consumer_key = '6qoZk0DOfaLF7q7RT1QoKQ'
#    consumer_secret = 'BhMUfJX0ipHcuPUBeOUfxh4HOOuXC6QPuSrohynH6I'
#    
#    @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "https://api.twitter.com/", :oauth_signature_method => "PLAINTEXT"})

    if !session[:oauth][:request_token].nil? && !session[:oauth][:request_token_secret].nil?
        @request_token = OAuth::RequestToken.new(@consumer, session[:oauth][:request_token], session[:oauth][:request_token_secret])
    end
        
    if !session[:oauth][:access_token].nil? && !session[:oauth][:access_token_secret].nil?
        @access_token = OAuth::AccessToken.new(@consumer, session[:oauth][:access_token], session[:oauth][:access_token_secret])
    end
end

get '/auth' do
    @access_token = @request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
    session[:oauth][:access_token] = @access_token.token
    session[:oauth][:access_token] = @access_token.secret
    redirect '/'
end

get "/request" do
    @request_token = @consumer.get_request_token(:oauth_callback => "http://#{request.host}/auth")
    session[:oauth][:request_token] = @request_token.token
    session[:oauth][:request_token_secret] = @request_token.secret
    redirect @request_token.authorize_url
end


get '/' do
	haml :index
end

get '/item' do
	haml :item
end
