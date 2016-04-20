module Split
  class User
    extend Forwardable
    def_delegators :@user, :keys, :[], :[]=, :delete
    attr_reader :user

    def initialize(context)
      @user = Split::Persistence.adapter.new(context)

      unless Split.configuration.allow_multiple_experiments
        cleanup_old_experiments
      end
      user
    end

    private

    def cleanup_old_experiments
      user.keys.each do |key|
        experiment = ExperimentCatalog.find key_without_version(key)
        if experiment.blank? || experiment.has_winner?
          user.delete key
        end
      end
    end

    def key_without_version(key)
      key.split(/\:\d(?!\:)/)[0]
    end
  end
end