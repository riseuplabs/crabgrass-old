class Student < Person
  acts_as_modified :except => :country
end
