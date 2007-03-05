class Wiki < ActiveRecord::Base
  has_many :pages, :as => :data
  def page
    pages.first
  end

  acts_as_versioned
  self.non_versioned_columns << 'body_html'
  
  format_attribute :body
  attr_accessible :body
  validates_presence_of :body, :on => :save
  
end
