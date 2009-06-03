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
      permission = controller.send("may_#{action}_#{controller.controller_name}?", *args)
    end
    if permission and block_given?
      yield
    else
      permission
    end
  end

  # shortcut for +may?+ but automatically selecting the current controller.
  def may_action?(action, *args, &block)
    may?(controller, action, *args, &block)
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
      link_to_active(link_text, {:controller => controller, :action => action, :id => object.nil? ? nil : object.id}.merge(link_opts), active)
    end
  end

  def method_missing(method_id, *args)
    super unless match = /may_([_a-zA-Z]\w*)\?/.match(method_id.to_s)
    super if /([_a-zA-Z]\w*)_#{controller.controller_name}/.match(match[1])
    permission = controller.send("may_#{match[1]}_#{controller.controller_name}?", *args)
    if permission and block_given?
      yield
    else
      permission
    end
  end
end
