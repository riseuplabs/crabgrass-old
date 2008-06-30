=begin

In development mode, rails is very aggressive about unloading and reloading
classes as needed. Unfortunately, for crabgrass page types, rails always gets
it wrong. To get around this, we create static proxy representation of the
classes of each page type and load the actually class only when we have to.

Furthermore, we keep a yaml representation of these proxy classes in
config/page_classes.yml. If you ever add or remove a Page subclass, you must
run this command:

  rake update_page_classes

That will regenerate page_classes.yml

The sillyness with page_classes.yml appears to be necessary. Requiring
all the page subclasses in environment.rb and building the proxy dynamically
on startup caused tons of problems.

=end

class PageClassRegistrar

  def self.proxies
    @@proxies ||= {}
  end

  def self.add(name, options)
    self.proxies[name] = PageClassProxy.new(options.merge(:class_name => name))
  end

  def self.list
    self.proxies.values
  end
  
  def self.proxy(arg)
    self.proxies[arg] || PageClassProxy.new
  end

end
