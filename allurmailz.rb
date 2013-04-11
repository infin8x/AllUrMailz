# allurmailz.rb
require 'sinatra'
require 'thin'
require 'haml'
require 'net/https'

class AllUrMailz < Sinatra::Base

    before do
        session[:oauth] ||= {}
        @consumer_key = 'V58Lo7BySs01zaXBOr1qhZHMMQIXSL'
        @consumer_secret = 'SMb4Z96sC1U1Rbk8To4WKaAyGqMw8L'
    end

    get '/auth' do
        http = Net::HTTP.new('app.smartfile.com',443)
        http.use_ssl = true

        path = '/oauth/access_token/'
        args = 'oauth_version=1.0&oauth_nonce=' + nonce.to_s + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_consumer_key=' + @consumer_key + '&oauth_token=' + session[:oauth][:request_token] + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%26' + session[:oauth][:request_token_secret] + '&oauth_verifier=' + params['verifier']

        res = http.post(path,args)
        split = res.body.split(/=|&/)

        session[:oauth][:access_token] = split[3]
        session[:oauth][:access_token_secret] = split[1]
        redirect '/'
    end

    def nonce
        rand(10 ** 30).to_s.rjust(30,'0')
    end

    get "/request" do
        http = Net::HTTP.new('app.smartfile.com', 443)
        http.use_ssl = true

        path = '/oauth/request_token/'
        args = 'oauth_version=1.0&oauth_nonce=' + nonce.to_s + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_consumer_key=' + @consumer_key + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%2526' + '&oauth_callback=' + CGI::escape('http://arapahoebasin.reshall.rose-hulman.edu/auth')  

        res = http.post(path, args)
        split = res.body.split(/=|&/)

        session[:oauth][:request_token] = split[3]
        session[:oauth][:request_token_secret] = split[1]

        redirect 'https://app.smartfile.com/oauth/authorize?oauth_token=' + CGI::escape(split[3])
    end


    get '/' do
        haml :index
    end

    get '/item' do
        haml :item
    end

    get '/whoami' do
        uri = URI.parse(URI.encode('https://app.smartfile.com/api/2/whoami?format=xml&oauth_consumer_key=' + @consumer_key + '&oauth_token=' + session[:oauth][:access_token] + '&oauth_signature_method=PLAINTEXT&oauth_signature=' + @consumer_secret + '%26' + session[:oauth][:access_token_secret] + '&oauth_timestamp=' + Time.now.to_i.to_s + '&oauth_nonce=' + nonce.to_s + '&oauth_version=1.0'))
        puts uri.host
        puts uri.port
        puts uri.request_uri
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Get.new(uri.request_uri)
        http.use_ssl = true

        puts uri

        # req['Authorization'] = 'OAuth realm="https://app.smartfile.com/",oauth_consumer_key="' + @consumer_key + '",oauth_token="' + session[:oauth][:access_token] + '",oauth_signature_method="PLAINTEXT",oauth_signature="' + @consumer_secret + '%26' + session[:oauth][:access_token_secret] + '",oauth_timestamp="' + Time.now.to_i.to_s + '",oauth_nonce="' + nonce.to_s + '",oauth_version="1.0"'

        res = http.request(req)
        puts res
        puts res.body
    end

end
