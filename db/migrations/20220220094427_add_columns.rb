Hanami::Model.migration do
  change do
    alter_table :news do
      add_column :body, String
    end
  end
end
