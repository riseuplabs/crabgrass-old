class Language < ActiveRecord::Base
  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code

  has_many :translations

  def self.all
    @all_langs ||= find(:all)
  end

  def link_html
    "<a href=\"/languages/#{ id }\">#{ name }</a>"
  end
end
