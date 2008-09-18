module UserExtension
  module Tags
    def self.included(base)
      base.instance_eval do
        serialize_as IntArray, :tag_id_cache
        initialized_by :update_tag_cache, :tag_id_cache

        has_many :tags, :finder_sql => 'SELECT DISTINCT tags.* FROM tags WHERE tags.id IN (#{tag_id_cache.to_sql})'
      end
    end
  end
end
