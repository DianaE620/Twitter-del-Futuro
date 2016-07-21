class User < ActiveRecord::Base
  # Remember to create a migration!
  has_many :tweets

  def self.tweets_update?(user)
    new_tweets = $client.user_timeline(user)
    old_tweets = User.find_by(twitter_handles: user).tweets.last

    if new_tweets[0].text == old_tweets.content
      true
    else
      false
    end

  end

  def test
    p self.tweets
  end

  def create_tweet(new_tweet)

    env_config = YAML.load_file(APP_ROOT.join('config', 'twitter.yaml'))

    env_config.each do |key, value|
      ENV[key] = value
    end

    cliente = Twitter::REST::Client.new do |config|
      config.consumer_key        = env_config["TWITTER_KEY"]
      config.consumer_secret     = env_config["TWITTER_SECRET"]
      config.access_token        = self.key
      config.access_token_secret = self.secret
    end

    self.tweets << Tweet.create(content: new_tweet)

    cliente.update(new_tweet)

    new_tweet

  end

  def tweet_later(text, time)
    # Crea un tweet relacionado con este usuario en la tabla de tweets
    tweet = Tweet.create(content: text)
    self.tweets << tweet
    # Este es un método de Sidekiq con el cual se agrega a la cola una tarea para ser
    # 
    TweetWorker.perform_in(time.minutes, tweet.id)
    #Estoy utilizando el metodo perfom de la clase TweetWorker pero indicando que se realice de manera asincrona
    #La última linea debe de regresar un sidekiq job id
  end

end
