class BuildBehavioursWorker
  include Sidekiq::Worker

  def initialize(behaviour_repo = BehaviourRepository.new)
    @behaviour_repo = behaviour_repo
  end

  def perform
    behaviour_repo.root.select(:id).pluck(:id).each do |id|
      BuildBehaviourWorker.perform_async(id)
    end
  end

  private

    attr_reader :behaviour_repo
end
