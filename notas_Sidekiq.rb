Utilizaremos Sidekiq que es una plataforma para procesar tareas en segundo plano (framework for background job processing). Esta plataforma utiliza Redis para poder guardar la información relevante de cada tarea.

Redis 
https://en.wikipedia.org/wiki/Redis

Sidekiq
https://github.com/mperham/sidekiq

Un ejemplo de sinatra y Sidekiq
https://github.com/mperham/sidekiq/blob/master/examples/sinkiq.rb

Agrega a tu Gemfile sidekiq y redis, luego dentro de config/environment.rb agrega sus requires respectivos. Como siempre deberás hacer bundle install.


Primero hay que levantar el servidor de Redis de la siguiente manera:

$ redis-server
Si quieres asegurarte que tu servidor de Redis está funcionando, ejecuta:

$ redis-cli ping
Ahora necesitamos levantar el servidor de Sidekiq:

$ bundle exec sidekiq -r ./config/environment.rb

Lee la documentación de Sidekiq
https://github.com/mperham/sidekiq/wiki