class ImportNewsDataWorker
  include Sidekiq::Worker

  HEADERS = %i(id category sub_category title abstract url title_entities abstract_entities).freeze
  IMPORT_FILE = File.join(File.dirname(__FILE__), '../../../MINDsmall_dev/news.tsv').freeze

  def initializer(new_repo = NewRepository.new)
    @new_repo = new_repo
  end

  def perform
    File.foreach(IMPORT_FILE, col_sep: "\t", headers: true) do |line|
      line = line.strip.split("\t")
      line = Hash[HEADERS.zip(line)]  
      line[:title_entities] = JSON.parse(line[:title_entities])

      NewRepository.new.create(**line)
    end
  end
end