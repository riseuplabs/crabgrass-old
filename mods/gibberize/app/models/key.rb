class Key < ActiveRecord::Base
  has_many :translations
  has_many :languages, :through => :translations

  # count number of translations for each key in given language
  # 
  # example: 
  #   Key.translations_in(languages(:english).id)[keys(:hello).id] == 1
  def self.count_translations_in(lang_id)
    trans_per_key = {}
    Key.find(:all).each {|k| trans_per_key[k.id] = 0}
    Translation.find(:all, :conditions => {:language_id => lang_id}).each { |t| trans_per_key[t.key_id] += 1 }
    
    return trans_per_key
  end

  def link_html
    "<a href=\"/keys/#{ id }\">#{ name }</a>"
  end
end
