web:	bundle exec unicorn -l 0.0.0.0:$PORT
redis:	redis-server
worker:	bundle exec rake resque:work QUEUE=*
