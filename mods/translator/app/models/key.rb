class Key < ActiveRecord::Base
  has_many :translations, :dependent => :destroy
  has_many :languages, :through => :translations

  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[A-Za-z0-9_]+\Z/

  ##
  ## FINDERS
  ##

  named_scope :translated, lambda { |language|
    {:include => :translations, :conditions => ['translations.site_id IS NULL AND translations.language_id = ?', language.id]}
  }

  named_scope :untranslated, lambda { |language|
      { :select => "`keys`.*",
        :joins =>
          'LEFT OUTER JOIN translations ON keys.id = translations.key_id AND translations.language_id = %i AND translations.site_id is NULL'%language.id,
          :conditions => 'translations.text IS NULL'}
    }

  named_scope :out_of_date, lambda { |language|
    { :joins => 'LEFT OUTER JOIN translations t1 ON keys.id = t1.key_id LEFT OUTER JOIN translations t2 ON keys.id = t2.key_id',
      :conditions =>
        ["t1.language_id = ? AND t2.language_id = ? AND t1.updated_at < t2.updated_at AND t1.site_id IS NULL AND t2.site_id IS NULL",
          language.id, Language.default.id]}
  }

  named_scope :by_name, :order => 'keys.name ASC'

  def untranslated_languages
    Language.find(:all) - self.languages
  end

  def default
    trans = Translation.find_by_key_id_and_language_id_and_site_id(self.id, Language.default.id, nil)
    return trans.text if trans and trans.text.any?
    return self.name.to_s.gsub('_', ' ')
  end

  def self.count_all
    @count ||= self.count().to_f
  end

  def to_param
    self.name
  end
end

=begin
# translated:

SELECT * FROM `keys` LEFT JOIN `translations` ON `translations`.key_id = `keys`.id WHERE `translations`.language_id = 5 LIMIT 0,1000

Key.find(:all, :joins => :translations, :conditions => ['language_id = ?', 5])


# untranslated:

SELECT * FROM `keys` LEFT OUTER JOIN `translations` ON keys.id = translations.key_id AND translations.language_id = 5 WHERE translations.text IS NULL


Key.find(:all, :joins => 'LEFT OUTER JOIN translations ON keys.id = translations.key_id AND translations.language_id = 5', :conditions => 'translations.text IS NULL')

# old:

SELECT * FROM `keys` JOIN `translations` t1 ON keys.id = t1.key_id JOIN `translations` t2 ON keys.id = t2.key_id WHERE t2.language_id = 4 AND t1.language_id = 5 AND t1.updated_at < t2.updated_at

Key.find(:all, :joins => 'LEFT OUTER JOIN translations t1 ON keys.id = t1.key_id JOIN translations t2 ON keys.id = t2.key_id', :conditions => 't1.language_id = 5 AND t2.language_id = 4 AND t1.updated_at < t2.updated_at')
=end
