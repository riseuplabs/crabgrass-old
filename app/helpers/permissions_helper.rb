module PermissionsHelper

  # returns +true+ if the +current_user+ is allowed to perform +action+ in
  # +controller+, optionally with some arguments.
  #
  # Make sure to include the corresponding permission in the controller.
  #
  # Examples:
  #   <%= "YOU ARE MY CREATOR" if may?(:group, :create) %>
  #   <%= "don't be editing that" unless may?(:group, :edit, @some_group) %>
  #
  #   <%- may?(:group, :frobnotz, @group) do -%>
  #     <h1>Frobnotzing Control</h1>
  #     <p>More stuff here…</p>
  #   <%- end -%>
  def may?(controller, action, *args)
    if controller.is_a?(Symbol)
      permission = send("may_#{action}_#{controller.to_s}?", *args)
    else
      permission = permission_for(controller, action, *args)
    end
    if permission and block_given?
      yield
    else
      permission
    end
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
    if may?(controller, action, object)
      link_to(link_text, {:controller => controller, :action => action, :id => object.nil? ? nil : object.name}.merge(link_opts), html_opts)
    end
  end

  def link_to_active_if_may(link_text, controller, action, object = nil, link_opts = {}, active=nil)
    if may?(controller, action, object)
      link_to_active(link_text, {:controller => controller.to_s, :action => action, :id => object.nil? ? nil : object.name}.merge(link_opts), active)
    end
  end

  def method_missing(method_id, *args)
    super unless match = /may_([_a-zA-Z]\w*)\?/.match(method_id.to_s)
    super if /([_a-zA-Z]\w*)_#{controller.controller_name}/.match(match[1])
    may?(controller, match[1], *args)
  end
  
  # this will try and use the may_action_controller? methods in the following
  # order:
  # 1) the controller name:
  #    asset_controller -> asset
  # 2) the name of the controllers parent namespace:
  #    me/trash_controller -> me
  # 3) the name of the controllers super class:
  #    event_page_controller -> base_page
  def permission_for(controller, action, *args)
    names=[]
    names << controller.controller_name
    names << controller.controller_path.split("/")[-2]
    names << controller.class.superclass.controller_name
    names.compact.each do |name|
      method="may_#{action}_#{name}?"
      return controller.send(method, *args) if controller.respond_to?(method)
    end
  end
end

