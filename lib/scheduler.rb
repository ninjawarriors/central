unless ENV['QUEUE']
  require 'json'
  require 'rufus-scheduler'
  require 'singleton'

  class Central
    get '/scheduler' do
      @schedules = Central.scheduler.all
      haml :scheduler
    end
    post '/scheduler' do
      Central.scheduler.add_schedule params unless params[:command] == ""
      redirect to('/scheduler')
    end
    delete '/scheduler/:id' do
      Central.scheduler.delete_cron params[:id]
      redirect to('/scheduler')
    end

    class Scheduler
      include Singleton
      def initialize
        @scheduler = Rufus::Scheduler.start_new
        @jobs = {}

        keys = $redis.keys "scheduler::cron::*"
        keys.each do |key|
          add_cron key, decode($redis.get key), false
        end
      end

      def decode item
        JSON.parse item
      end

      def add_cron id, params, new = true
        if new
          $redis.sadd "scheduler::cron", id
          $redis.set "scheduler::cron::#{id}", params.to_json
        end
        @jobs[id] == @scheduler.cron("#{params['min']} #{params['hr']} #{params['date']} #{params['month']} #{params['day']}") do
          Resque.enqueue(CommandRun, Central.counter, params['command'])
        end
      end

      def add_schedule item
        params = item.is_a?(Hash)? item : decode(item)
        if params['repeat'] == "yes"
          params.delete "repeat"
          add_cron Central.counter, params
        else
          Resque.enqueue(CommandRun, Central.counter, params['command'])
        end
      end

      def delete_cron id
        $redis.del "scheduler::cron::#{id}"
        $redis.srem "scheduler::cron", id
        @scheduler.unschedule @jobs[id]
        @jobs.delete id
      end

      def all
        ids = $redis.smembers "scheduler::cron"
        crons = {}
        ids.each do |id|
          crons[id] = decode($redis.get "scheduler::cron::#{id}")
        end
        crons
      end
    end
  end

  Central::Scheduler.instance
end
