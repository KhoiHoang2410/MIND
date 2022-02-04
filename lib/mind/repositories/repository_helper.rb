module RepositoryHelper
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

  private

    def normalize_data_for_update(**data)
      data.each do |k, v|
        data[k] = (v.empty? ? '{}' : Sequel.pg_array(v)) if v.is_a?(Array) && !v.first.is_a?(Hash)
        data[k] = Sequel.pg_jsonb(v) if v.is_a?(Hash) || (v.is_a?(Array) && v.to_a.first.is_a?(Hash))
      end
    end
end