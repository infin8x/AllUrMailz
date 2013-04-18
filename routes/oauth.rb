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