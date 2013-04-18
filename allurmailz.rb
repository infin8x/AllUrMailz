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
require './mail/stats'

class AllUrMailz < Sinatra::Application
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
end

require_relative 'routes/init'
