get '/' do
    haml :index
end

get '/getEmail' do
    haml :getEmail, :locals => {:server => session[:exchange][:server], :username => session[:exchange][:username]}
end

get '/selectFolders' do
    haml :selectFolders, :locals => {:dataUrl => root_url + "/data/selectFolders"}
end

get '/viewEmail' do
    haml :viewEmail
end