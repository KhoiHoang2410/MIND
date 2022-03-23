namespace :data do
  desc 'Clean data'
  task clean: :environment do
    new_repo = NewRepository.new
    behaviour_repo = BehaviourRepository.new

    deleted_new_ids = new_repo.root.read(
      <<~SQL
        DELETE FROM news
        WHERE body = '' or category = 'video' or title_entities = '{}' or abstract_entities = '[]' or body isnull
        RETURNING id;
      SQL
    ).to_a.map(&:id)

    behaviour_repo.root.read(
      <<~SQL
        DELETE FROM behaviours
        WHERE user_id NOT IN(
          SELECT user_id
          FROM behaviours
          WHERE array_length(histories, 1) >= 20
          GROUP BY user_id
          HAVING COUNT(*) >= 5
          ORDER BY COUNT(*) desc
        );
      SQL
    ).to_a

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

    deleted_new_ids.each do |new_id|
      PostProcessDeleteNewIDWorker.perform_async(new_id)
    end
  end
end
