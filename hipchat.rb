require 'sinatra'
require 'sinatra-logentries'
require 'hipchat'
require 'rest-client'
require 'json'
#require './config.rb'

client = HipChat::Client.new(ENV['HIPCHAT_API_TOKEN'], :api_version => 'v2')

set :environment, :production

configure do
  Sinatra::Logentries.token = '9fee7149-af22-4119-94e7-300c824e0925'
end

get '/test-post' do
	# 'username' is the name for which the message will be presented as from
	#client['miketest'].send('@neptune', 'I talk')

	# Send notifications to users (default false)
	#client['my room'].send('username', 'I quit!', :notify => true)

	# Color it red. or "yellow", "green", "purple", "random" (default "yellow")
	#client['my room'].send('username', 'Build failed!', :color => 'red')

	# Have your message rendered as text in HipChat (see https://www.hipchat.com/docs/apiv2/method/send_room_notification)
	client['Commerce'].send('@neptune', '<table><th>Image</th><tr><td><img src="http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2015/4/24/1429874666489/168b8f53-fa5c-4798-a571-6d614875509e-1020x612.png"/></td></tr></table>', :message_format => 'html', :notify => true, :color => 'random')
	client['Pinnacle - Jackthreads'].send('@neptune', '<table><th>Image</th><tr><td><img src="http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2015/4/24/1429874666489/168b8f53-fa5c-4798-a571-6d614875509e-1020x612.png"/></td></tr></table>', :message_format => 'html', :notify => true, :color => 'random')
end

get '/' do
	puts "hello"
end

get '/set_subscription' do
	puts params.inspect
	response = params["hub.challenge"]
	puts response
	response
end

post '/set_subscription' do
	push = JSON.parse(request.body.read)
	puts push

	media_id = push[0]["data"]["media_id"]
	puts "media id"
	puts media_id

	url = "https://api.instagram.com/v1/media/" + media_id
	puts "url"
	puts url

	response = JSON.parse(RestClient.get(url, {:params => {:access_token => ENV['INSTAGRAM_ACESS_TOKEN_NEPTUNE']}, :accept => :json} ) )
	img_url = response["data"]["images"]["standard_resolution"]["url"]
	caption = response["data"]["caption"]["text"]
	link = response["data"]["link"]
	puts img_url

	client['Commerce'].send("@neptune", "<table><th>#{caption}</th><tr><td><a href='#{link}' target='_blank'><img src='#{img_url}'/></a></td></tr></table>", :message_format => 'html', :notify => true, :color => 'random')
	client['Pinnacle - Jackthreads'].send('@neptune', '<table><th>Image</th><tr><td><img src="http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2015/4/24/1429874666489/168b8f53-fa5c-4798-a571-6d614875509e-1020x612.png"/></td></tr></table>', :message_format => 'html', :notify => true, :color => 'random')
end

get '/authorize' do
	puts ENV['INSTAGRAM_AUTH_URL']
	redirect ENV['INSTAGRAM_AUTH_URL']
end

get '/auth-redirect' do
	access_token = request.fullpath.split('#access_token=')[1]
	if access_token == nil
		puts params.inspect
		code = params["code"]

		system "curl -F '#{ENV["INSTAGRAM_CLIENT_ID"]}' \
			-F 'client_secret=#{ENV["INSTAGRAM_CLIENT_SECRET"]}' \
			-F 'grant_type=authorization_code' \
			-F 'redirect_uri=#{ENV["INSTAGRAM_OAUTH_REDIRECT_URI"]}' \
			-F 'code=#{code}' \
			https://api.instagram.com/oauth/access_token"
	else
		puts access_token
	end

=begin
	data = {
		"client_id" => INSTAGRAM_CLIENT_ID,
		"client_secret" => INSTAGRAM_CLIENT_SECRET,
		"grant_type" => "authorization_code",
		"redirect_uri" => INSTAGRAM_OAUTH_REDIRECT_URI,
		"code" => code
	}.to_json

	puts data

	headers = {
		:"Content-Type" => "application/json"
	}

	response = RestClient.post( "http://api.instagram.com/oauth/access_token", data, headers)
	puts response
=end
end

get '/easy-auth' do
	access_token = request.fullpath.split('#access_token=')[1]
	if access_token == nil
		instagram_auth = "https://instagram.com/oauth/authorize/?client_id=#{ENV['INSTAGRAM_CLIENT_ID']}&redirect_uri=#{ENV['INSTAGRAM_EASY_AUTH_REDIRECT_URI']}&response_type=token"
		puts instagram_auth
		redirect instagram_auth
	else
		puts access_token
	end
end

get '/easy-auth/redirect' do
	access_token = request.fullpath.split('#')[1]
	puts access_token
end