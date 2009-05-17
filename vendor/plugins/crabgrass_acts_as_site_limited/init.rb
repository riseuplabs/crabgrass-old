
require File.dirname(__FILE__) + '/lib/acts_as_site_limited'

ActiveRecord::Base.class_eval { include ActsAsSiteLimited }

