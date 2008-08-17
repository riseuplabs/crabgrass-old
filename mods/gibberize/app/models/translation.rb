class Translation < ActiveRecord::Base
  belongs_to :key
  belongs_to :language

  validates_presence_of :key, :language, :text

  def self.best_guess(key, language)
    t = Translation.find(:first, :conditions => {:key_id => key, :language_id => language})
    t.text if t
  end
  
  def self.wanted_from(user)
    t = Translation.new
# task: set t.language, t.key = (language,key)-pair that 
# we dont know well and that user will be able supply
# objective: choose something that will be "fun" for user to translate.
#   elements of fun include: not too hard and not too easy, similar to
# previous translations but not too similar, don't change from_lang and
# to_lang frequently, but do respect user's choice
    t.language_id, cnt = user.count_translations_by_language_id.find { |lang_id, cnt| cnt > 0 }
    t.key_id, cnt = Key.count_translations_in(t.language_id).find { |key_id, cnt| cnt == 0 }
    
    return t
  end

  def link_html
    "<a href=\"/translations/#{ id }\">#{ text }</a>"
  end

end
