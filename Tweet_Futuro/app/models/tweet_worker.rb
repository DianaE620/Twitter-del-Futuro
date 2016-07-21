class TweetWorker
  include Sidekiq::Worker

  def perform(tweet_id)
    # Encuentra el tweet basado en el 'tweet_id' pasado como argumento
    tweet = Tweet.find(tweet_id)

    # Utilizando relaciones deberás encontrar al usuario relacionado con dicho tweet
    user  = tweet.user

    # Manda a llamar el método del usuario que crea un tweet (user.tweet)
    user.create_tweet(tweet.content)
  end

end