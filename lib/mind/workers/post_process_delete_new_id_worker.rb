class PostProcessDeleteNewIDWorker
  include Sidekiq::Worker

  def initialize(new_repo = NewRepository.new, behaviour_repo = BehaviourRepository.new)
    @new_repo = new_repo
    @behaviour_repo = behaviour_repo
  end

  def perform(new_id)
    behaviour_repo
      .root
      .where(
        Sequel.lit(
          "histories::TEXT ILIKE '%" + new_id.to_s + "%'
            OR impressions::TEXT ILIKE '%" + new_id.to_s + "%'"
        )
      )
      .map_to(Behaviour)
      .to_a
      .each do |behaviour|
        histories = behaviour.histories.select { |behaviour_new_id| behaviour_new_id != new_id  }
        impressions_data = []
        impressions = behaviour.impressions.select do |impression|
          impression_new_id, impress = impression.split('-')
          next false if impression_new_id == new_id

          impressions_data << { new: impression_new_id, impress: impress }
        end

        behaviour_repo.update(behaviour.id, histories: histories, impressions: impressions, impressions_data: impressions_data)
      end
  end

  private

    attr_reader :new_repo, :behaviour_repo
end
