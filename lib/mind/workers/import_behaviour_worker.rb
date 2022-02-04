class ImportBehaviourWorker
  include Sidekiq::Worker

  def initialize(behaviour_repo = BehaviourRepository.new)
    @behaviour_repo = behaviour_repo
  end

  def perform(data)
    data = JSON.parse(JSON(data), symbolize_names: true)
    @behaviour_repo.upsert(**data)
  end
end