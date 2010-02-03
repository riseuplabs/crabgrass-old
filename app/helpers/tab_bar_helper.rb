module TabBarHelper

  # thing is what this contents of this tab
  # thing usually is controller name, but can be anything if :current option is set
  # thing + "_tab" is used as an I18n.t key for the text, when :translate option is blank
  # thing + "_path" is used for url when :controller or :action options are blank
  # options:
  #   :translate - the name of the I18n.t key for the text
  #   :action, :controller, :id, :other_param - used for linking
  #   :current - if this options is true, then this tab will be active
  def tab_li(thing, options = {})
    thing = thing.to_s if thing.is_a?(Symbol)
    current = options.delete :current
    current ||= controller.controller_name == thing
    li_class = current ? 'current' : ''
    li_class += " #{options.delete(:class)}" if !options[:class].nil?
    key = options.delete :translate
    key ||= (thing + '_tab').to_sym
    named_path = (thing + '_path').to_sym
    uppercase = options.delete :upcase
    if options.empty? and respond_to?(named_path)
      target = send named_path
    else
      target = options
    end
    content_tag(:li, :class => li_class) do
      uppercase ? link_to(I18n.t(key).upcase, target) : link_to(I18n.t(key).capitalize, target)
    end
  end

  # thing is a name of the action
  # the tab will be active if params[:action] is same as thing
  # see tab_li for other options
  def action_tab_li(thing, options = {})
    thing = thing.to_s if thing.is_a?(Symbol)
    options.merge! :current => (params[:action] == thing), :action => thing
    tab_li thing, options
  end
end
