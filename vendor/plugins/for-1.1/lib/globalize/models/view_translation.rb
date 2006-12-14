module Globalize
  # Represents a view translation in the DB, which is a translation of a string
  # in the rails application itself. This includes error messages, controllers,
  # views, and flashes, but not database content.
  class ViewTranslation < Translation # :nodoc:

    def self.pick(key, language, idx)
      find(:first, :conditions => [ 
        'tr_key = ? AND language_id = ? AND pluralization_index = ?', 
        key, language.id, idx ])
    end

  end
end
