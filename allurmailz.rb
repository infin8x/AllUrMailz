# allurmailz.rb
require 'sinatra'
require 'thin'
require 'haml'

get '/' do
	haml :index
end

get '/item' do
	haml :item
end
