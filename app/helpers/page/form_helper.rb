##
## PAGE FORM HELPERS
##

module Page::FormHelper

  protected

  def display_page_class_grouping(group)
    I18n.t("page_group_#{group.gsub(':','_')}".to_sym)
  end

  def tree_of_page_types(available_page_types=nil, options={})
    available_page_types ||= current_site.available_page_types
    page_groupings = []
    available_page_types.each do |page_class_string|
      page_class = Page.class_name_to_class(page_class_string)
      next if page_class.nil? or page_class.internal
      if options[:simple]
        page_groupings << page_class.class_group.to_a.first
      else
        page_groupings.concat page_class.class_group
      end
    end
    page_groupings.uniq!
    tree = []
    page_groupings.each do |grouping|
      entry = {:name => grouping, :display => display_page_class_grouping(grouping),
         :url => grouping.gsub(':','-')}
      entry[:pages] = Page.class_group_to_class(grouping).select{ |page_klass|
       !page_klass.internal && available_page_types.include?(page_klass.full_class_name)
      }.sort_by{|page_klass| page_klass.order }
      tree << entry
    end
    return tree.sort_by{|entry| PageClassProxy::ORDER.index(entry[:name])||100 }
  end

  ## options for a page type dropdown menu for searching
  def options_for_select_page_type(default_selected=nil)
    available_types = current_site.available_page_types
    # used by options_for_select helpe
    menu_items = []

    # collect [display_name, url] pairs for all pages
    available_types.each do |klass_name|
      klass = Page.class_name_to_class(klass_name)
      next if klass.nil? or klass.internal

      display_name = klass.class_display_name
      url = klass.url
      menu_items << [display_name, url]
    end

    # sort by display name
    menu_items.sort!
    # create select attributes
    options_for_select([[I18n.t(:all_page_types),'']] + menu_items, default_selected)
  end

  ## Creates options useable in a select() for the various states
  ## a page might be in. Used to filter on these states
  def options_for_page_states(parsed_path)
    selected = ''
    selected = 'pending' if parsed_path.keyword?('pending')
    selected = 'unread' if parsed_path.keyword?('unread')
    selected = 'starred' if parsed_path.keyword?('starred')
    selected = parsed_path.first_arg_for('page_state') if parsed_path.keyword?('page_state')
    options_for_select(['unread','pending','starred'].to_localized_select, selected)
  end

end
