class Animal < ActiveRecord::Base
  acts_as_modified
  
  set_primary_key 'animal_id'
end
