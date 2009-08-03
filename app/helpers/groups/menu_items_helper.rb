module Groups::MenuItemsHelper

  def autocomplete_service_url
    "/groups/menu_items/auto_complete/" + @group.name
  end

  def autocomplete_item_selected_function(autocomplete_id)
    function_code = remote_function({
      :url => {:controller => 'groups/menu_items', :action => 'create', :id => @group.name},
      :with => %{'page_id=' + data},
      :update => 'menu_items_list_container',
      :loading => show_spinner(autocomplete_id),
      :complete => hide_spinner(autocomplete_id)
    })

    # submit the name and clear the input box
    "function(value, data) { #{function_code}; $('page_name').value='';}"
  end

  def new_autocomplete_javascript(autocomplete_id)
    %Q[
      new Autocomplete('page_name', {
        serviceUrl:'#{autocomplete_service_url}',
        minChars:1,
        maxHeight:500,
        width:400,
        onSelect: #{autocomplete_item_selected_function(autocomplete_id)},
      }, '#{autocomplete_id}');
    ]
  end

  def destroy_menu_item_remote_function(menu_item, button_id)
    remote_function({
      :url => {:controller => 'groups/menu_items', :action => 'destroy', :id => @group.name},
      :with => %Q['menu_item_id=' + #{menu_item.id}],
      :method => :delete,
      :update => 'menu_items_list_container',
      :loading => spinner_icon_on('minus', button_id),
      :complete => spinner_icon_off('minus', button_id)
    })
  end

  def edit_menu_item_remote_function(menu_item, button_id)
    remote_function({
      :url => {:controller => 'groups/menu_items', :action => 'edit', :id => @group.name},
      :with => %Q['menu_item_id=' + #{menu_item.id}],
      :loading => spinner_icon_on('pencil', button_id),
      :complete => spinner_icon_off('pencil', button_id)
    })
  end

  def save_menu_item_remote_function(menu_item, button_id)
    remote_function({
      :url => {:controller => 'groups/menu_items', :action => 'update', :id => @group.name},
      :with => %Q['menu_item_id=' + #{menu_item.id}],
      :loading => spinner_icon_on('pencil', button_id),
      :complete => spinner_icon_off('pencil', button_id)
    })
  end

  def cancel_add_menu_item_function(menu_item, button_id)
    update_page do |page|
      page.remove dom_id(menu_item)
    end
  end

  def cancel_edit_menu_item_remote_function(menu_item, button_id)
    remote_function({
      :url => {:controller => 'groups/menu_items', :action => 'edit', :id => @group.name},
      :with => %Q['menu_item_id=' + #{menu_item.id}],
      :loading => spinner_icon_on('pencil', button_id),
      :complete => spinner_icon_off('pencil', button_id)
    })
  end

  def add_menu_item_button(spinner_id, disabled=false)
    button_to_remote("Add".t, {
      :url    => groups_menu_items_url(:action=>'new'),
      :html   => {:action => groups_menu_items_url(:action=>'new')}, # non-ajax fallback
      :loading => show_spinner(spinner_id),
      :loaded => hide_spinner(spinner_id)
    },
      :id => 'add_menu_item_button'
    )
  end

  def cancel_menu_item_button(spinner_id)
    url = groups_menu_items_url(:action=>'update', :_method => :put)
    button_to_remote "Cancel".t,
      :url      => url, # same as for the form. Update without data will just reload.
      :html     => {:action => url}, # non-ajax fallback
      :update => 'menu_items_list_container',
      :loading  => show_spinner(spinner_id)
  end

  def handle_update_menu_item_order_javascript(container_id, spinner_id)
    # require 'ruby-debug';debugger;1-1
    sortable_element container_id,
        :tag => 'tr',
        :handle => 'menu_item_drag_handle',
        :ghosting => true,
        :constraint => :vertical,
        :url => { :controller => 'groups/menu_items', :action => 'update', :id => @group.name},
        :update => 'menu_items_list_container',
        :method => :put,
        :loading => show_spinner(spinner_id),
        :loaded => hide_spinner(spinner_id)
    end
end
