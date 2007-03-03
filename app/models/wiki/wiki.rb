class Wiki::Wiki < ActiveRecord::Base
  acts_as_versioned
  format_attribute :body
  attr_accessible :body
  
  validates_presence_of :body
end
