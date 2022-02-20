require_relative 'repository_helper'

class NewRepository < Hanami::Repository
  include ::RepositoryHelper

  def upsert(id:, **data)
    data = normalize_data_for_update(data)
    New.new root.dataset
      .insert_conflict(
        target: :id,
        update: {
          id: Sequel[:excluded][:id],
          **data
        }
      )
      .returning
      .insert(
        id: id,
        **data
      )
      .first
  end
end
