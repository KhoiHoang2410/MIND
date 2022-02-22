require 'open-uri'

File.open('mind_development.sql', 'w') do |stream|
  stream << URI.open('https://drive.google.com/uc?export=download&id=1B4FEYdqaAQfsTqkzXgq-NhVD8ybIri0-').read
end
