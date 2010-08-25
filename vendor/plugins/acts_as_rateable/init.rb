# Include hook code here
require 'acts_as_rateable'
ActiveRecord::Base.send(:include, Juixe::Acts::Rateable)

# require File.dirname(__FILE__) + '/lib/acts_as_rateable'
# require File.dirname(__FILE__) + '/lib/rating'
# ActiveRecord::Base.send(:include, Juixe::Acts::Rateable)


