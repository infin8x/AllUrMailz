get '/' do
    haml :index
end

get '/getEmail' do
    haml :getEmail, :locals => {:server => session[:exchange][:server], :username => session[:exchange][:username]}
end

get '/viewEmail' do
    haml :viewEmail
end

get '/viewTagCloud/:sname' do
	c = APICommands.new(session[:caller])
	@tags = c.GetWordStatistics(params[:sname])
    haml :viewTagCloud, :locals => {:tags => @tags}
end
