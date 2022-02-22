Hanami::Model.migration do
  change do
    alter_table :news do
      add_column :body, String
    end

    alter_table :behaviours do
      add_column :impressions_data, 'jsonb', default: '{}', null: false
    end
  end
end
