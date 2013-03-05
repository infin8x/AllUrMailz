# allurmailz.rb
require 'sinatra'
require 'haml'

get '/' do
	haml :index
end