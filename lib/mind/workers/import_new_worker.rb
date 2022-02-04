class ImportNewWorker
  include Sidekiq::Worker

  def initialize(new_repo = NewRepository.new)
    @new_repo = new_repo
  end

  def perform(data)
    data = JSON.parse(JSON(data), symbolize_names: true)
    @new_repo.upsert(**data)
  end
end