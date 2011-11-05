web:	bundle exec thin start -p $PORT
worker:	VVERBOSE=true QUEUE=* bundle exec rake resque:work
