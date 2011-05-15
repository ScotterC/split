require 'redis'
REDIS = Redis.new

module Multivariate
  class Experiment
    attr_accessor :name
    attr_accessor :alternatives

    def initialize(name, *alternatives)
      @name = name
      @alternatives = alternatives
    end

    def save
      REDIS.del(@name)
      @alternatives.each {|a| REDIS.sadd(name, a) }
    end

    def self.find(name)
      if REDIS.exists(name)
        self.new(name, *REDIS.smembers(name))
      else
        raise 'Experiment not found'
      end
    end

    def self.find_or_create(name, *alternatives)
      if REDIS.exists(name)
        return self.new(name, *REDIS.smembers(name))
      else
        experiment = self.new(name, *REDIS.smembers(name, *alternatives))
        experiment.save
        return experiment
      end
    end
  end
end