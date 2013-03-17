# allurmailz.rb
require 'sinatra'
require 'haml'

get '/' do
	layout :bootstrap
	haml :index
end

get '/item' do
	haml :item
end