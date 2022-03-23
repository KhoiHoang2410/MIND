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
      nokogiri = Nokogiri::HTML.parse(URI.open(new.url).read)
      {
        body: nokogiri.css('p').text,
        created_at: Time.strptime("#{nokogiri.xpath("//time").first.text.strip} 00:00:00Z", '%m/%d/%Y %H:%M:%S%Z')
      }
    end
end
