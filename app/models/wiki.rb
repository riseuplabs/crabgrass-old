class Wiki < ActiveRecord::Base
  
  has_many :pages, :as => :data
  def page; pages.first; end

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
