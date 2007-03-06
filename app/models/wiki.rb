#require 'redcloth'

class Wiki < ActiveRecord::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
#  include WhiteListHelper
  
  #has_many :pages, :as => :data
  #def page
  #  pages.first
  #end

  acts_as_versioned
  #self.non_versioned_columns << 'body_html'
  
  #format_attribute :body
  #attr_accessible :body
  #validates_presence_of :body, :on => :update
  
  def before_save
     self.body_html = format_wiki_text(body)
  end

  
  def format_wiki_text(text)
    html = text.strip
    html = auto_link(html) do |link|
        truncate(link, 50)
    end
    html = RedCloth.new(html).to_html
  end
   
end
