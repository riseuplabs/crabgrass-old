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
  # defines the permission mixin to be in charge of instances of this controller
  # and related views.
  #
  # for example:
  #   permissions 'foo_bar', :bar_foo
  #
  # will attempt to load the +FooBarPermission+ and +BarFooPermission+ classes
  # and apply them considering permissions for the current controller and views.
  def self.permissions(*class_names)
    for class_name in class_names
      begin
        permission_class = "#{class_name}_permission".camelize.constantize
      rescue NameError # permissions 'groups' => Groups::BasePermission
        permission_class = "#{class_name}/base_permission".camelize.constantize
      end
      include(permission_class)
      add_template_helper(permission_class)

      #@@permissioner = Object.new
      #@@permissioner.extend(permission_class)
    end
  end
end

  # returns the permissioner in charge of instances of this controller class
  #def self.permissioner
  #  @@permissioner
  #end

  # returns the permissioner in charge of this controller class
  #def permissioner
  #  @@permissioner
  #end

###
### handle truncate compatibility betweeen rails 2.1 and 2.3
###
class ActionView::Base
#
# This make truncate compatible with rails 2.1 and rails 2.3
#
  def truncate_with_compatible_code(text, options={})
    length = options[:length] || 30
    omission = options[:omission] || "..."
    if Rails::version == "2.1.0"
      truncate_without_compatible_code(text, length, omission)
    else
      truncate_without_compatible_code(text, options)
    end
  end

  alias_method_chain :truncate, :compatible_code
end
