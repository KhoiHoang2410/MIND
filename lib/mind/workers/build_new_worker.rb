class BuildNewWorker
  include Sidekiq::Worker

  def initialize(new_repo = NewRepository.new)
    @new_repo = new_repo
  end

  def perform(id)
    @new = new_repo.find(id)
    return unless new

    new_repo.update(id, **normalize_data)
  end

  private

    attr_reader :new_repo, :new

    def normalize_data
      {
        body: Nokogiri::HTML.parse(URI.open(new.url).read).css('p').text
      }
    end
end
