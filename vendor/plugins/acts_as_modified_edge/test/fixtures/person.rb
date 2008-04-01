class Person < ActiveRecord::Base
  acts_as_modified
  
  belongs_to :school
end
