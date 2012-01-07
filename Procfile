web:	bundle exec thin start -p $PORT
redis:	redis-server
worker:	bundle exec rake resque:work QUEUE=*
