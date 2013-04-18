get '/data/accounts' do
    c = APICommands.new(session[:caller])
    accountNames = c.GetAccountNames
    accounts = Array.new
    accountNames.each do |account|
        thisOne = Hash.new
        thisOne[:account] = account
        accounts << thisOne
    end
    accounts.to_json
end

get '/data/:sname' do
    begin
        c = APICommands.new(session[:caller])
        folderNames = c.GetMailFolders(params[:sname])
        folderArray = Array.new
        folderNames.each do |folder|
            thisOne = Hash.new
            thisOne[:folder] = folder
            folderArray << thisOne
        end
        folderArray.to_json
    rescue
        404
    end
end

get '/data/:sname/:fname' do
    headers \
        "Content-Type" => "application/json"
    c = APICommands.new(session[:caller])
    toReturn = c.GetMessagesFromFolder(params[:sname], URI.encode(params[:fname]))
    toReturn
    # kennedle@exchange.rose-hulman.edu/Class%20Information
end

get '/read/:sname/:fname' do
    haml :selectEmails, :locals => {:currentFolder => params[:fname], :dataUrl => root_url + "/data/#{params[:sname]}/#{params[:fname]}", :emailBaseUrl => root_url + "/read/#{params[:sname]}/#{params[:fname]}/"}
end

get '/read/:sname/:fname/:iid' do
    c = APICommands.new(session[:caller])
    @email = c.GetEmail(params[:sname], URI.encode(params[:fname]), params[:iid])
    @email.body
end