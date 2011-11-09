web:	bundle exec thin start -p $PORT
redis:	redis-server
worker:	QUEUE=* bundle exec rake resque:work
