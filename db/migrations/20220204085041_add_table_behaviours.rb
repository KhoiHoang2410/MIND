Hanami::Model.migration do
  change do
    create_table :behaviours do
      primary_key :id, String
  
      column :user_id, String, null: false
      column :histories, 'text[]', null: false, default: '{}'
      column :impressions, 'text[]', nul: false, default: '{}'

      column :created_at, DateTime, null: false, default: 'now()'
      column :updated_at, DateTime, null: false, default: 'now()'
    end
  end
end
