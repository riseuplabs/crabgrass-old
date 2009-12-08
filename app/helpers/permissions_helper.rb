module PermissionsHelper

  # returns +true+ if the +current_user+ is allowed to perform +action+ in
  # +controller+, optionally with some arguments.
  #
  # permissions are resolved in this order:
  #
  # (1) check to see if a method is defined that matches may_action_controller?()
  # (2) check the class hierarchy for such a method (replacing controller name
  #     with the appropriate controller).
  # (3) fall back to default_permission
  # (4) return false if we had no success so far.
  #
  def may?(controller, action, *args)
    permission = permission_for_controller(controller, action, *args)
    if permission and block_given?
      # return nil, if yield returns false
      yield
    else
      permission
    end
  end

  # i don't think there should be a default permission globally, because
  # then you will never get an error when you call a permission that doesn't
  # exist.
  #def default_permission(*args)
  #  false
  #end

  # shortcut for +may?+ but automatically selecting the current controller.
  # only use this in authorized? and similar situations where the user is
  # actually trying to do the action. It may display error messages if the
  # user may not take that action.
  # Use may? or link_if_may or the permission method itself to determine if
  # a user may theoretically do something (in order to display the link for
  # example)
  def may_action?(action=params[:action], *args, &block)
    permission = may?(controller, action, *args, &block)
    if !permission and @error_message
      flash_message_now :error => @error_message
    end
    permission
  end

  # Generate a link to the specific action if the user is allowed to do
  # so, skipping it otherwise.
  #
  # Examples:
  #   <%= link_if_may("Create a Group", :group, :create) %>
  #   <%= link_if_may("Edit this Group", :group, :edit, @group) %>
  #   <%= link_if_may("Delete this Group", :group, :delete, @group, :confirm => "Are you sure?") %>
  #   <%= link_if_may("Boldly go", :warp_drive, :enable, nil, {}, {:style => "font-weight: bold;"} %>
  def link_if_may(link_text, controller, action, object = nil, link_opts = {}, html_opts = nil)
    if may?(controller, action, object)
      object_id = params_object_id(object)
      link_to(link_text, {:controller => controller, :action => action, :id => object_id}.merge(link_opts), html_opts)
    end
  end

  def link_to_active_if_may(link_text, controller, action, object = nil, link_opts = {}, active=nil)
    if may?(controller, action, object)
      object_id = params_object_id(object)
      link_to_active(link_text, {:controller => controller.to_s, :action => action, :id => object_id}.merge(link_opts), active)
    end
  end

  # matches may_x?
  PERMISSION_METHOD_RE = /^may_([_a-zA-Z]\w*)\?$/

  # Call may?() if the missing method is in the form of a permission test (may_x?)
  # and call super() otherwise.
  #
  # There are two exceptions to this rule:
  #
  # (1) We do not call super() if we are a controller. Instead, we mimic the behavior
  # of ActionController:Base#perform_action. I don't know why, but calling super()
  # in the case causes problems.
  #
  # (2) We do not call super() if the superclass does not have method_missing
  # defined, since this will cause an error.
  #
  def method_missing(method_id, *args)
    method_id = method_id.to_s
    match = PERMISSION_METHOD_RE.match(method_id)
    if match
      result = may?(controller, match[1], *args)
      if result.nil?
        raise Exception.new('could not find permission definition for %s' % method_id)
      else
        result
      end
    elsif self.is_a? ActionController::Base
      if template_exists?(method_id) && template_public?(method_id)
        # TODO: template_exists?() always returns false for tools.
        # for now, this means that tools must explictly define every action.
        nil # ActionController::Base will render the template
      else
        raise NameError, "No method #{method_id}", caller
      end
    elsif self.class.superclass.method_defined?(:method_missing)
      super
    else
      raise NameError, "No method #{method_id}", caller
    end
  end

  private

  # searches for an appropriate permission definition for +controller+.
  #
  # permissions are generally in the form may_{action}_{controller}?
  #
  # Both the plural and the singular are checked (ie GroupsController#edit will
  # check may_edit_groups? and may_edit_group?). Whichever one is first defined
  # will be used.
  #
  # For the 'controller' part, many different possibilities are tried,
  # in the following order:
  #
  # 1) the controller name:
  #    asset_controller -> asset
  # 2) the name of the controller's parent namespace:
  #    me/trash_controller -> me
  #    base_page/share_controller -> page ("base_" is stripped off)
  # 3) the name of the controller's super class:
  #    event_page_controller -> page ("base_" is stripped off)
  # 4) ensure "page" is in there somewhere if controller descends from
  #    BasePageController (the controller might be a subclass of a subclass
  #    of base page)
  #
  # Note: 'base_xxx' is always converted into 'xxx'
  #
  # Alternately, if controller is a string:
  #
  # 1) the string
  #    'groups' -> groups
  # 2) the postfix
  #    'groups/memberships' -> memberships
  # 3) the prefix
  #    'groups/memberships' -> 'groups'
  #
  # Alternately, if controller is a symbol:
  #
  # 1) the symbol
  #
  # Lastly, if the action consists of two words (ie 'eat_soup'), the
  # the permissions without a controller name is attempted (ie 'may_eat_soup?)
  #
  def permission_for_controller(controller, action, *args)
    names=[]
    if controller.is_a? ApplicationController
      names << controller.controller_name
      names << controller.controller_path.split("/")[-2]
      names << controller.class.superclass.controller_name
      names << 'page' if controller.is_a? BasePageController
      target = controller
    elsif controller.is_a? String
      if controller =~ /\//
        names = controller.split('/').reverse
      else
        names << controller
      end
      target = self
    elsif controller.is_a? Symbol
      names << controller.to_s
      target = self
    end
    names.compact.each do |name|
      name.sub!(/^base_/, '')
      methods = ["may_#{action}_#{name}?"]
      methods << "may_#{action}_#{name.singularize}?" if name != name.singularize
      methods << "may_#{action}?" if action =~ /_/
      methods.each do |method|
        return target.send(method, *args) if target.respond_to?(method)
      end
    end
    if target.respond_to?('default_permission')
      return target.send('default_permission', *args)
    end
    return nil
  end

  # the first one that makes sense in this order: object.name, object.id, nil
  def params_object_id(object)
    object_id = if object.respond_to?(:name)
      object.name
    elsif !object.blank?
      object.id
    end
  end
end

