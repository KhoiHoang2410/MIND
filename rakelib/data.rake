namespace :data do
  desc 'Clean data'
  task clean: :environment do
    new_repo = NewRepository.new
    behaviour_repo = BehaviourRepository.new

    new_repo.root.read(
      <<~SQL
        DELETE FROM news
        WHERE body = '' or category = 'video';
      SQL
    ).to_a

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

    behaviour_repo.all.select do |behaviour|
      histories = behaviour.histories.select { |new_id| new_repo.find(new_id) }
      impressions_data = []
      impressions = behaviour.impressions.select do |impression|
        new_id, impress = impression.split('-')
        next false unless new_repo.find(new_id)

        impressions_data << { new: new_id, impress: impress }
      end

      behaviour_repo.update(behaviour.id, histories: histories, impressions: impressions, impressions_data: impressions_data)
    end
  end
end
