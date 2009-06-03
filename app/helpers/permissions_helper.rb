module PermissionsHelper

  # returns +true+ if the +current_user+ is allowed to perform +action+ in
  # +controller+, optionally with some arguments.
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
      controller = "#{controller}_controller".camelize.constantize
    end
    permission = controller.send("may_#{action}?", *args)
    yield if permission and block_given?
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

  def method_missing(method_id, *args)
    return unless match = /may_([_a-zA-Z]\w*)\?/.match(method_id.to_s)
    return if /([_a-zA-Z]\w*)_#{controller.controller_name}/.match(match[1])
    permission = controller.send("may_#{match[1]}_#{controller.controller_name}?", *args)
    yield if permission and block_given?
  end
end
