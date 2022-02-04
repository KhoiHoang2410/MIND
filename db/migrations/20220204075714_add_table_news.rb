Hanami::Model.migration do
  change do
    create_table :news do
      primary_key :id, String
  
      column :category, String
      column :sub_category, String
      column :title, String
      column :abstract, String
      column :url, String
      column :title_entities, 'jsonb', default: '{}', null: false
      column :abstract_entities, 'jsonb', default: '{}', null: false

      column :created_at, DateTime, null: false, default: 'now()'
      column :updated_at, DateTime, null: false, default: 'now()'
    end
  end
end
