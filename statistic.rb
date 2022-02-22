# Get Hash of news and frequently
hash = BehaviourRepository.new.root.select(:histories).pluck(:histories).to_a.flatten.group_by(&:itself).transform_values!(&:size)

=begin

group_news_by_histories.json

keys: news id
values: frequency

hash = {
  "N42620": 10116,
  "N306": 9733,
  "N45794": 7678,
  "N43142": 6971
}

hash.size # 37681
hash.values.max = 10116
hash.values.min = 1

90%CI = [275, 1]
95%CI = [511, 1]

=end
