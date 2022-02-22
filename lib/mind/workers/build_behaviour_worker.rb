class BuildBehaviourWorker
  include Sidekiq::Worker

  def initialize(behaviour_repo = BehaviourRepository.new)
    @behaviour_repo = behaviour_repo
  end

  def perform(id)
    @behaviour = behaviour_repo.find(id)
    return unless behaviour

    behaviour_repo.update(id, **normalize_data)
  end

  private

    attr_reader :behaviour_repo, :behaviour

    def normalize_data
      {
        impressions_data: behaviour.impressions.map do |impression|
          Hash[[:new, :impress].zip(impression.split('-'))]
        end
      }
    end
end
