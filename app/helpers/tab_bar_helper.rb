module TabBarHelper

  def tab_li(thing, options = {})
    thing = thing.to_s if thing.is_a?(Symbol)
    current = options.delete :current
    current ||= controller.controller_name == thing
    key = options.delete :translate
    key ||= (thing + '_tab').to_sym
    named_path = (thing + '_path').to_sym
    if options.empty? and respond_to?(named_path)
      target = send named_path
    else
      target = options
    end
    li_class = current ? 'current' : ''
    content_tag(:li, :class => li_class) do
      link_to I18n.t(key).upcase, target
    end
  end

  def action_tab_li(thing, options = {})
    thing = thing.to_s if thing.is_a?(Symbol)
    options.merge! :current => (params[:action] == thing), :action => thing
    tab_li thing, options
  end
end
