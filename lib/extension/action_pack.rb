### 
### VIEW INHERITANCE
### 

# View inheritance is the ability of a subclassed controller to fall back on
# the views of its parent controller. This code is a adapted from these patches:
# http://dev.rubyonrails.org/ticket/7076

ActionController::Base.class_eval do
  def default_template_name(action_name = self.action_name, klass = self.class)
    if action_name && klass == self.class
      action_name = action_name.to_s
      if action_name.include?('/') && template_path_includes_controller?(action_name)
        action_name = strip_out_controller(action_name)
      end
    end
    if !klass.superclass.method_defined?(:controller_path) 
      return "#{self.controller_path}/#{action_name}" 
    end
    template_name = "#{klass.controller_path}/#{action_name}"        
    if template_exists?(template_name) 
      return template_name 
    else 
      return default_template_name(action_name, klass.superclass) 
    end 
  end
end

ActionView::PartialTemplate.class_eval do
  private
  def partial_pieces(view, partial_path)
    if partial_path.include?('/')
      return File.dirname(partial_path), File.basename(partial_path)
    else
      return partial_controller_find(view, partial_path)
    end
  end

  def partial_controller_find(view, partial_path, klass = view.controller.class) 
    if view.finder.file_exists?("#{klass.controller_path}/_#{partial_path}")  
      return klass.controller_path, partial_path 
    elsif !klass.superclass.method_defined?(:controller_path)  
      # End of the inheritance line 
      return view.controller.class.controller_path, partial_path 
    else  
      return partial_controller_find(view, partial_path, klass.superclass)  
    end  
  end
end

### 
### MULTIPLE SUBMIT BUTTONS
### 

# It is nice to be able to have multiple submit buttons.  For non-ajax, this
# works fine: you just check the existance in the params of the :name of the
# submit button. For ajax, this breaks, and is labelled wontfix 
# (http://dev.rubyonrails.org/ticket/3231). This hack is an attempt to get
# around the limitation. By disabling the other submit buttons we ensure that
# only the submit button that was pressed contributes to the request params.

class ActionView::Base
  alias_method :rails_submit_tag, :submit_tag
  def submit_tag(value = "Save changes", options = {})
    #options[:id] = (options[:id] || options[:name] || :commit)
    options.update(:onclick => "Form.getInputs(this.form, 'submit').each(function(x){if (x!=this) x.disabled=true}.bind(this))")
    rails_submit_tag(value, options)
  end
end


###
### LINK_TO FOR COMMITTEES
###
  
# I really want to be able to use link_to(:id => 'group+name') and not have
# it replace '+' with some ugly '%2B' character.

class ActionView::Base
  def link_to_with_pretty_plus_signs(*args)
    link_to_without_pretty_plus_signs(*args).sub('%2B','+')
  end
  alias_method_chain :link_to, :pretty_plus_signs
end

###
### CUSTOM FORM ERROR FIELDS
###

# Rails form helpers are brutal when it comes to generating
# error markup for fields that fail validation
# they will surround every input with .fieldWithErrors divs
# and will mess up your layout. but there is a way to customize them
# http://pivotallabs.com/users/frmorio/blog/articles/267-applying-different-error-display-styles
class ActionView::Base
  def with_error_proc(error_proc)
    pre = ActionView::Base.field_error_proc
    ActionView::Base.field_error_proc = error_proc
    yield
    ActionView::Base.field_error_proc = pre
  end
end

###
### PERMISSIONS DEFINITION
###
ActionController::Base.class_eval do
  # defines the permissioner to be in charge of instances of this controller
  # class
  #
  # for example:
  #   permissioner 'foo_bar'
  # will attempt to load the +FooBarPermission+ class and apply it when
  # considering permissions for the current controller class. You could also
  # pass in a symbol (i.e., <tt>permissioner :foo_bar</tt>) if you're so
  # inclined.
  def self.permissions(class_name)
    permission_class = "#{class_name}_permission".camelize.constantize
    include(permission_class)

    @@permissioner = Object.new
    @@permissioner.extend(permission_class)
  end

  # returns the permissioner in charge of instances of this controller class
  def self.permissioner
    @@permissioner
  end

  # returns the permissioner in charge of this controller class
  def permissioner
    @@permissioner
  end
end

