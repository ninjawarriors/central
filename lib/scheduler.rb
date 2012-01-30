unless ENV['QUEUE']
  require 'json'
  require 'rufus-scheduler'
  require 'singleton'

  class Central
    class Scheduler
      include Singleton
      def initialize
        @scheduler = Rufus::Scheduler.start_new

        crons = $redis.smembers "scheduler::cron"
        crons.each do |cron|
          add_schedule cron, false
        end
      end

      def decode item
        JSON.parse item
      end

      def add_schedule item, new = true
        params = item.is_a?(Hash)? item : decode(item)
        if params['repeat'] == "yes"
          $redis.sadd "scheduler::cron", params.merge({"id" => Central.counter}).to_json if new
          @scheduler.cron "#{params['min']} #{params['hr']} #{params['date']} #{params['month']} #{params['day']}" do
            Resque.enqueue(CommandRun, Central.counter, params['command'])
          end
        else
          Resque.enqueue(CommandRun, Central.counter, params['command'])
        end
      end
    end
  end

  Central::Scheduler.instance
end
