post '/getEmail' do
    puts params
    session[:exchange][:server] = params['server']
    session[:exchange][:username] = params['username']
    session[:exchange][:password] = params['password']
    puts session[:exchange]
end

get '/data/selectFolders' do
    session[:retriever] = MailRetriever.new(session[:exchange][:username], session[:exchange][:password], session[:exchange][:server], session[:caller])
    session[:retriever].getFolders
end

post '/selectFolders' do
    request.body.rewind
    data =  request.body.read
    converted = eval(data)
    result = session[:retriever].retrieveMailFromFolders(converted)
end	