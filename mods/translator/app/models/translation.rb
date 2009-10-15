class Translation < ActiveRecord::Base
  belongs_to :key
  belongs_to :language
  belongs_to :site

  validates_presence_of :key, :language, :text

  named_scope :for_language, lambda { |language|
    {:conditions => ['language_id = ?', language.id]}
  }

  def validate_on_create
    if Key.find(key_id).languages.include?(Language.find(language_id))
      errors.add("language_id", "already has a translation")
    end
  end

  # returns the text for this translation in the default language
  # (or the key if no default trans exists)
  def default_text
    key.default
  end

  def default
    Translation.find_by_key_id_and_language_id(self.key.id, Language.default.id)
  end

  def out_of_date?
    def_trans = default()
    return def_trans && def_trans.updated_at > self.updated_at
  end

end

