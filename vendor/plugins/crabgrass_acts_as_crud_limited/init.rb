require File.dirname(__FILE__) + '/lib/acts_as_crud_limited'

ActiveRecord::Base.class_eval { include ActsAsCrudLimited }

