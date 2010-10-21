=begin

Context: a class to represent the current context. 

Eventually, Context may become an ActiveRecord, to allow users to
customize the appearance and behavior of their context.

Identity Context
-------------------

An identity context sets the "place" for a person or group. It tells use where
we are and what we can do here. Most importantly, it gives us a sense of the
identify of the person or group whose space we are in.

Context Banner
-----------------------

The banner is the main display that shows the current context. 

Available options:

 :size     -- [:small | :large]
 :avatar   -- [true | false]

=end

class Context

  attr_accessor :tab
  attr_accessor :entity
  attr_accessor :parent
  attr_accessor :navigation
  attr_accessor :breadcrumbs

  # appearance:
  attr_accessor :size
  attr_accessor :avatar
  attr_accessor :fg_color
  attr_accessor :bg_color
  attr_accessor :bg_image
  attr_accessor :bg_image_position

  #attr_accessor :links
  #attr_accessor :form

  def initialize(entity)
    self.entity = entity
    self.define_crumbs
    self.size = :large
    self.avatar = true
    self.bg_color = '#ccc'
    self.fg_color = 'white'
  end

  def push_crumb(object)
    if self.breadcrumbs.nil?
      self.breadcrumbs = []
      self.tab = object
    end
    self.breadcrumbs << object
  end

  protected

  def define_crumbs()
  end

end

class Context::Group < Context
  
  def define_crumbs
    push_crumb :groups
    if self.entity and !self.entity.new_record?
      push_crumb self.entity
    end
  end

end

class Context::Network < Context::Group

  def define_crumbs
    push_crumb :networks
    if self.entity and !self.entity.new_record?
      push_crumb self.entity
    end
  end

end

class Context::Committee < Context::Group
  def define_crumbs
    push_crumb :groups
    if self.entity and !self.entity.new_record?
      push_crumb self.entity.parent
      push_crumb self.entity
    end
  end
end

class Context::Council < Context::Committee
end

class Context::Me < Context
  def define_crumbs
    push_crumb :me
  end
end

class Context::Person < Context
  def define_crumbs
    push_crumb :people
    if self.entity and !self.entity.new_record?
      push_crumb self.entity
    end
  end
end


