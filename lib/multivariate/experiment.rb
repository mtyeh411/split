module Multivariate
  class Experiment
    attr_accessor :name
    attr_accessor :alternatives

    def initialize(name, *alternatives)
      @name = name.to_s
      @alternatives = alternatives
    end

    def alternatives
      @alternatives.map {|a| Multivariate::Alternative.find_or_create(a, name)}
    end

    def random_alternative
      alternatives[rand(alternatives.size)]
    end

    def save
      Multivariate.redis.sadd(:experiments, name)
      @alternatives.each {|a| Multivariate.redis.sadd(name, a) }
    end

    def self.all
      Array(Multivariate.redis.smembers(:experiments)).map {|e| find(e)}
    end

    def self.find(name)
      if Multivariate.redis.exists(name)
        self.new(name, *Multivariate.redis.smembers(name))
      else
        raise 'Experiment not found'
      end
    end

    def self.find_or_create(name, *alternatives)
      if Multivariate.redis.exists(name)
        return self.new(name, *Multivariate.redis.smembers(name))
      else
        experiment = self.new(name, *alternatives)
        experiment.save
        return experiment
      end
    end
  end
end