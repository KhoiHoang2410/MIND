class BuildNewsWorker
  include Sidekiq::Worker

  def initialize(new_repo = NewRepository.new)
    @new_repo = new_repo
  end

  def perform
    new_repo.root.select(:id).pluck(:id).each do |id|
      BuildNewWorker.perform_async(id)
    end
  end

  private

    attr_reader :new_repo
end
