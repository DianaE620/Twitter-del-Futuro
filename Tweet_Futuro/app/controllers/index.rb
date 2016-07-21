get '/' do
  # La siguiente linea hace render de la vista 
  # que esta en app/views/index.erb

  erb :index
end


get '/tweet' do
  erb :new_tweet
end

get '/tweets' do
  erb :tweets
end

post '/tweet' do
  new_tweet = params[:newTweet]

  usuario = User.find_by(twitter_handles: session[:consumer_name])

  usuario.create_tweet(new_tweet)

end

get '/later/tweet' do
  erb :later
end

post '/later/tweet' do
  tweet = params[:laterTweet]
  time = params[:time].to_i

  usuario = User.find_by(twitter_handles: session[:consumer_name])

  usuario.tweet_later(tweet, time)

end

get '/status/:job_id' do
  # regresa el status de un job a una petición AJAX
  job_id = params[:job_id]

  hash_status = {}

  if job_is_complete(job_id)
    hash_status = { estatus: "complete" }
  else
    hash_status = { estatus: "incomplete" }
  end

  hash_status.to_json

end

get '/login/twiiter' do
  # El método `request_token` es uno de los helpers
  # Esto lleva al usuario a una página de twitter donde sera atentificado con sus credenciales
  redirect request_token.authorize_url(:oauth_callback => "http://#{host_and_port}/auth")
  # Cuando el usuario otorga sus credenciales es redirigido a la callback_url 
  # Dentro de params twitter regresa un 'request_token' llamado 'oauth_verifier'
end

get '/auth' do
  # Volvemos a mandar a twitter el 'request_token' a cambio de un 'acces_token' 
  # Este 'acces_token' lo utilizaremos para futuras comunicaciones.   
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # Despues de utilizar el 'request token' ya podemos borrarlo, porque no vuelve a servir. 
  
  session.delete(:request_token)

  # Aquí es donde deberás crear la cuenta del usuario y guardar usando el 'acces_token' lo siguiente:
  # nombre, oauth_token y oauth_token_secret
  # No olvides crear su sesión 

  session[:consumer_key] = @access_token.token
  session[:consumer_secret] = @access_token.secret
  session[:consumer_name] = @access_token.params[:screen_name]

  if User.find_by(twitter_handles: session[:consumer_name])
    usuario = User.find_by(twitter_handles: session[:consumer_name])
    usuario.update(key: session[:consumer_key], secret: session[:consumer_secret])

    redirect to('/profile/user')
  else
    User.create(twitter_handles: session[:consumer_name], key: session[:consumer_key], secret: session[:consumer_secret] )
    redirect to('/profile/user')
  end
end

get '/profile/user' do
  erb :profile
end

post '/ajax/twitter' do 
  twitteruser = params[:tweet]
  user_name = $client.user(twitteruser).screen_name
  user_tweets = $client.user_timeline(twitteruser)

  if User.find_by(twitter_handles: user_name)
    usuario_twitter = User.find_by(twitter_handles: user_name)
    unless User.tweets_update?(user_name)
      for i in 0..9 do
        usuario_twitter.tweets << Tweet.find_or_create_by(content: user_tweets[i].text)
        break if i == usuario_twitter.tweets.count - 1
      end
    end
  else
    usuario_twitter = User.create(twitter_handles: user_name)
    for i in 0..9 do
      usuario_twitter.tweets << Tweet.create(content: user_tweets[i].text)
      break if i == user_tweets.count - 1
    end
  end 

  tweets_objects = User.find_by(twitter_handles: user_name).tweets.last(10)

  tweets = []
  tweets_objects.each do |t|
    tweets << "<li>" + t.content + "</li><br>"
  end

  tweets

end

get '/logout/session' do
  session.clear
  redirect to('/')
end





