module BasePage::ShareHelper

  # returns option tags usable in a select menu to choose a page owner.
  #
  # There are four types of entries:
  #
  #  (1) groups the user is a (direct or indirect) member of
  #  (2) the user
  #  (3) 'none' if !Conf.ensure_page_owner?
  #  (4) the current owner, even if it doesn't meet one of the other criteria.
  #
  #
  # accepted options:
  #
  #  :selected     -- the item to make selected (either string or group object)
  #  :include_me   -- if true, include option for 'me'
  #  :include_none -- if true, include an option for 'none'
  #
  def options_for_page_owner(options={})
    items = current_user.primary_groups_and_networks.sort { |a, b|
       a.display_name.downcase <=> b.display_name.downcase
    }.collect {|group| {:value => group.name, :label => group.name, :group => group} }

    selected_item = nil

    if options[:selected]
      if options[:selected].nil?
        # this method was called with :selected => nil
        options[:include_none] = true
      elsif options[:selected].is_a? String
        selected_item = options[:selected].sub(' ', '+')   # sub '+' for committee names
      elsif options[:selected].respond_to?(:name)
        selected_item = options[:selected].name
      end
    end

    if !Conf.ensure_page_owner?
      options[:include_none] = true
    end

    if options[:include_none]
      items.unshift(:value => '', :label => I18n.t(:none), :style => 'font-style: italic')
      selected_item ||= ''
    end

    if options[:include_me]
      items.unshift(:value => current_user.name, :label => "%s (%s)" % [I18n.t(:only_me), current_user.name], :style => 'font-style: italic')
      selected_item ||= current_user.name
    end

    unless items.detect{|i| i[:value] == selected_item}
      # we have a problem: item list does not include the one that is supposed to be selected. so, add it.
      items.unshift(:value => selected_item, :label => selected_item)
    end

    html = []

    items.collect do |item|
      selected = ('selected' if item[:value] == selected_item)
      html << content_tag(
        :option,
        h(truncate(item[:label], :length => 40)),
        :value => item[:value],
        :class => 'spaced',
        :selected => selected,
        :style => item[:style]
      )
      if item[:group]
        item[:group].committees.each do |committee|
          selected = ('selected' if committee.name == selected_item)
          html << content_tag(
            :option,
            h(truncate(committee.short_name, :length => 40)),
            :value => committee.name,
            :class => 'indented',
            :selected => selected
          )
        end
      end
    end
    html.join("\n")
  end

  def page_access_options(options={})
    @access_options ||= [
      [I18n.t(:page_access_admin),'admin'],
      [I18n.t(:page_access_edit),'edit'],
      [I18n.t(:page_access_view),'view']
    ]
    if options[:remove]
      @access_options + [[I18n.t(:page_access_none),'remove']]
    elsif options[:blank]
      @access_options + [["(%s)" % I18n.t(:no_change),'']]
    else
      @access_options
    end
  end

  # displays the access level of a participation.
  # eg:
  #   <span class="admin">Full Access</span>
  #
  def display_access(participation)
    if participation
      access = participation.access_sym.to_s
      if access.empty? and @page
        participation = @page.most_privileged_participation_for(participation.entity)
        access = participation.access_sym.to_s
      end
      option = page_access_options.find{|option| option[1] == access}
      if option
        content_tag :span, option[0], :class => access
      end
    end
  end

  def display_access_icon(participation)
    icon = case participation.access_sym
      when :admin then 'tiny_wrench'
      when :edit then 'tiny_pencil'
      when :view then 'tiny_no_pencil'
    end
    icon_tag(icon)
  end

  #
  # creates a select tag for page access
  #
  # There are two forms:
  #
  #   select_page_access(name, participation, options)
  #   select_page_access(name, options)
  #
  # options:
  #
  #  [blank] if true, include 'no change' as an option
  #  [expand] if true, show as list instead of popup.
  #  [remove] if true, show an entry that allows for access removal
  #
  def select_page_access(name, participation={}, options=nil)
    options = participation if participation.is_a?(Hash)

    selected = participation.try(:access_sym) || options[:selected]
    options.reverse_merge!(:blank => true, :expand => false, :remove => false, :class => 'access')

    select_options = page_access_options(:blank => options[:blank], :remove => options.delete(:remove))
    if options.delete(:blank)
      selected ||= ''
    else
      selected ||= Conf.default_page_access
    end
    if options.delete(:expand)
      options[:size] = select_options.size
    end
    select_tag name, options_for_select(select_options, selected.to_s), options
  end

  protected

  def add_action(recipient, access, spinner_id)
    access ||= may_select_access_participation? ?
      "$('recipient[access]').value" :
      "'#{Conf.default_page_access}'"
    {
      :url => {:controller => 'base_page/share', :action => 'update', :page_id => nil, :add => true},
      :with => %{'recipient[name]=#{recipient.name}&recipient[access]=' + #{access}},
      :loading => spinner_icon_on('spacer', spinner_id),
      :complete => spinner_icon_off('spacer', spinner_id)
      }
  end

  # the remote action that is triggered when the 'add' button is pressed (or
  # the popup item is selected).
  def widget_add_action(action, add_button_id, access_value)
    {
      :url => {:controller => 'base_page/share', :action => action, :page_id => @page.id, :add => true},
      :with => %{'recipient[name]=' + $('recipient_name').value + '&recipient[access]=' + #{access_value}},
      :loading => spinner_icon_on('plus', add_button_id),
      :complete => spinner_icon_off('plus', add_button_id)
    }
  end

  # (1) submit the form when the enter key is pressed in the text box
  # (2) don't submit the form if the recipient name field is empty
  # (3) eat the event by returning false on a enter key so that the form
  #     is not submitted.
  def add_recipient_widget_autocomplete_tag(add_action)
    # this is called after an item in the popup has been selected.
    # it makes it so selecting an item is like hitting the add button
    # we clear the recipient_name field so that we don't get a double submit
    after_update_function = "function(value, data) { #{remote_function(add_action)}; $('recipient_name').value='';}"

    autocomplete_entity_tag('recipient_name',
                        :onselect => after_update_function,
                        :message => I18n.t(:entity_autocomplete_tip),
                        :container => 'autocomplete_container')
  end

  def add_recipient_widget_key_press_function(add_action)
    eat_enter = "return(!enterPressed(event));"
    only_on_enter_press = "enterPressed(event) && $('recipient_name').value != ''"
    remote_function(add_action.merge(:condition => only_on_enter_press)) + eat_enter;
  end

end

