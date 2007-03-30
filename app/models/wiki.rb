class Wiki < ActiveRecord::Base
  
  has_many :pages, :as => :data
  
  # we do this so that we can access the page even before it is saved
  def page
    return pages.first if pages.any?
    return @page
  end
  def page=(p)
    @page = p
  end
  
  belongs_to :user
  
  acts_as_versioned
  #self.non_versioned_columns << 'body_html'
  
  #format_attribute :body
  #attr_accessible :body
  #validates_presence_of :body, :on => :update
  
  def before_save
     self.body_html = format_wiki_text(body)
  end
  
  def format_wiki_text(text)
    GreenCloth.new(text, (page.main_group_name || 'page') ).to_html
  end
   
end
