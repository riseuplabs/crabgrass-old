### misc definition used by tests

module Tool; end

class ParamHash < HashWithIndifferentAccess
end

def mailer_options
  {:site => Site.new(), :current_user => users(:blue), :host => 'localhost',
  :protocol => 'http://', :port => '3000', :page => @page}
end
