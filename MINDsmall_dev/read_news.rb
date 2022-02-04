require "json"
require 'byebug'

headers = %i(id category sub_category title abstract url title_entities abstract_entities).freeze

hash_ary = []
File.open("meibo.json","w") do |json|
  File.foreach("news.tsv", col_sep: "\t", headers: true) do |line|
    line = line.strip.split("\t")
    line = Hash[headers.zip(line)]  
    line[:title_entities] = JSON.parse(line[:title_entities])
    hash_ary << JSON.pretty_generate(line)
  end
  json.puts(hash_ary)
end
