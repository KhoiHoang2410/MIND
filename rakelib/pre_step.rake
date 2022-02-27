namespace :data do
  desc 'Clean data'
  task clean: :environment do
    new_repo = NewRepository.new
    behaviour_repo = BehaviourRepository.new
    sql = <<~SQL
      DELETE FROM behaviours
      WHERE user_id not IN(
        SELECT user_id
        FROM behaviours
        GROUP BY user_id
        HAVING COUNT(*) >= 5
        ORDER BY COUNT(*) desc
      );
    SQL

    behaviour_repo.root.read(sql).to_a

    new_ids = behaviour_repo
      .root
      .select(:histories, :impressions_data)
      .to_a
      .map(&:to_h)
      .map(&:values)
      .map do |e| 
        [e[0], e[1].map(&:values).map(&:first)]
          .flatten
          .uniq
      end
      .flatten
      .uniq

    new_repo.root.exclude(id: new_ids).delete
  end
end
