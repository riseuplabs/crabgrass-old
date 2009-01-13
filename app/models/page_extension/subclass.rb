=begin

SUPPORT FOR PAGE SUBCLASSING

All page types are handled by 'tools' that are really just plugins that live
in the tools directory.

The methods in this module make use of the constant PAGES. This is hash of
PageClassProxy objects. PageClassProxy objects store information about the
page, but they they are just dummy classes. 

In development mode, rails is very aggressive about unloading and reloading
classes as needed. Unfortunately, for crabgrass page types, rails always gets
it wrong. To get around this, we create static proxy representation of the
classes of each page type and load the actually class only when we have to.

To subclass a page, put something like this in the tool's init.rb:

PageClassRegistrar.add(
  'MyPage',
  :controller => 'my_page',
  :icon => 'package.png',
  :class_display_name => 'mine',
  :class_description => 'a page that is all mine',
  :class_group => 'asset', 
  :order => 20
)

then, in tools/mytool/models/mypage.rb

  class MyPage < Page
  end

=end

module PageExtension::Subclass

  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do
      include InstanceMethods
    end
  end
    
  module InstanceMethods    
    def class_definition
      PAGES[self.class.name] || PageClassProxy.new
    end
    def icon
      class_definition.icon
    end
    def controller
      class_definition.controller
    end
    def controller_class_name
      class_definition.controller_class_name
    end
  end

  module ClassMethods
    # PAGES is a static hash in the form:
    # { :discussion => <DiscussionPageProxy>, :asset => <AssetPageProxy> }

    # lets us convert from a url pretty name to the actual class.
    def display_name_to_class(display_name)
      dn = display_name.nameize
      (PAGES.detect{|t|
        t[1].class_display_name.nameize == dn if t[1].class_display_name
      } || [])[1]
    end
     
    # return an array of page classes that are members of class_group
    # eg: 'poll' -> ['RateManyPage', 'RankedVotePage']
    # each class group may have many pages in it, and each page may be in
    # many class groups.
    def class_group_to_class_names(class_group)
      return [] unless class_group.any?
      PAGES.values.collect do |proxy|
        proxy.class_name if proxy.class_group.include?(class_group)
      end.compact
    end
     
    # convert from a string representation of a class to the
    # real thing (actually, a proxy)
    def class_name_to_class(class_name)
      (PAGES.detect{|t|
        t[1].class_name == class_name or t[1].class_name == "#{class_name}Page"
      } || [])[1]
    end

    def class_definition
      PAGES[name] || PageClassProxy.new
    end
    
    def icon
      class_definition.icon
    end
    def controller
      class_definition.controller
    end
    def controller_class_name
      class_definition.controller_class_name
    end
    def class_display_name
      class_definition.class_display_name
    end
    def class_description
      class_definition.class_description
    end
    #The names used in Site.available_page_types; inverse of class_name_to_class
    def short_class_name
      class_definition.full_class_name.sub("Page","")
    end
  end
  
end
