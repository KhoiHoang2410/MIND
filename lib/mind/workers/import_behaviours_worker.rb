class ImportBehavioursWorker
  include Sidekiq::Worker

  HEADERS = %i(id user_id created_at histories impressions).freeze
  IMPORT_FILE = File.join(File.dirname(__FILE__), '../../../MINDsmall_train/behaviors.tsv').freeze

  def perform
    File.foreach(IMPORT_FILE, col_sep: "\t") do |line|
      line = line.strip.split("\t")
      line = Hash[HEADERS.zip(line)]
      line[:histories] = line[:histories].split(' ')
      line[:impressions] = line[:impressions].split(' ')
      ImportBehaviourWorker.perform_async(line)
    end
  end
end
