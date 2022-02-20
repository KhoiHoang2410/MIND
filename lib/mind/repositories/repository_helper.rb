module RepositoryHelper
  private

    def normalize_data_for_update(**data)
      data.each do |k, v|
        data[k] = (v.empty? ? '{}' : Sequel.pg_array(v)) if v.is_a?(Array) && !v.first.is_a?(Hash)
        data[k] = Sequel.pg_jsonb(v) if v.is_a?(Hash) || (v.is_a?(Array) && v.to_a.first.is_a?(Hash))
      end
    end
end