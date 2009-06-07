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
    if controller.is_a?(Symbol)
      permission = send("may_#{action}_#{controller.to_s}?", *args)
    else
      method = permission_method_for_controller(controller, action)
      permission = controller.send(method, *args)
    end

    if permission and block_given?
      yield
    else
      permission
    end
  end

  def default_permission(*args)
    false
  end

  # shortcut for +may?+ but automatically selecting the current controller.
  # only use this in authorized? and similar situations where the user is
  # actually trying to do the action. It may display error messages if the
  # user may not take that action.
  # Use may? or link_if_may or the permission method itself to determine if
  # a user may theoretically do something (in order to display the link for
  # example)
  def may_action?(action, *args, &block)
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
    may?(controller, action, object) do
      link_to(link_text, {:controller => controller, :action => action, :id => object.nil? ? nil : object.id}.merge(link_opts), html_opts)
    end
  end

  def link_to_active_if_may(link_text, controller, action, object = nil, link_opts = {}, active=nil)
    may?(controller, action, object) do
      link_to_active(link_text, {:controller => controller.to_s, :action => action, :id => object.nil? ? nil : object.id}.merge(link_opts), active)
    end
  end

  def method_missing(method_id, *args)
    super unless match = /may_([_a-zA-Z]\w*)\?/.match(method_id.to_s)
    super if /([_a-zA-Z]\w*)_#{controller.controller_name}/.match(match[1])
    may?(controller, match[1], *args)
  end
  
  private

  # this will try and use the may_action_controller? methods in the following
  # order:
  # 1) the controller name:
  #    asset_controller -> asset
  # 2) the name of the controllers parent namespace:
  #    me/trash_controller -> me
  # 3) the name of the controller's super class:
  #    event_page_controller -> base_page
  # 4) ensure "base_page" is in there somewhere if controller descends from it
  #    (the controller might be a subclass of a subclass of base page)
  def permission_method_for_controller(controller, action)
    names=[]
    names << controller.controller_name
    names << controller.controller_path.split("/")[-2]
    names << controller.class.superclass.controller_name
    names << 'base_page' if controller.is_a? BasePageController
    names.compact.each do |name|
      method="may_#{action}_#{name}?"
      return method if controller.respond_to?(method)
    end
    return 'default_permission'
  end
end

