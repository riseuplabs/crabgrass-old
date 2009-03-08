module BasePageHelper
  def select_page_access(name, options={})
    selected = params[name]
    options = {:blank => true, :expand => false}.merge(options)
    select_options = [['Coordinator'[:coordinator],'admin'],['Participant'[:participant],'edit'],['Viewer'[:viewer],'view']]
    if options[:blank]
      select_options = [['(' + 'select access level' + ')','']] + select_options
      selected ||= ''
    else
      selected ||= 'admin'
    end
    if options[:expand]
      select_tag name, options_for_select(select_options, selected), :size => select_options.size
    else
      select_tag name, options_for_select(select_options, selected)
    end
  end
end
