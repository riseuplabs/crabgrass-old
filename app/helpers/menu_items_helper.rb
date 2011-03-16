module MenuItemsHelper

  def form_remote_for_menu_item (menu_item, spinner_id)
    options = { :loading => show_spinner(spinner_id) }
    form_remote_for([@widget, menu_item], options) do |f|
      yield f
    end
  end

  def destroy_menu_item_remote_function(menu_item, spinner_id)
    remote_function({
      :url => widget_menu_item_url(@widget, menu_item),
      :method => :delete,
      :update => 'menu_items_form_container',
      :loading => show_spinner(spinner_id),
      :complete => hide_spinner(spinner_id)
    })
  end

#  def edit_menu_item_remote_function(menu_item, button_id)
#    remote_function({
#      :url => {:controller => 'groups/menu_items', :action => 'edit', :id => @group.name},
#      :with => %Q['menu_item_id=' + #{menu_item.id}],
#      :loading => spinner_icon_on('pencil', button_id),
#      :complete => spinner_icon_off('pencil', button_id)
#    })
#  end

  def save_menu_item_remote_function(menu_item, spinner_id)
    remote_function({
      :url => widget_menu_item_url(@widget, menu_item),
      :loading => show_spinner(spinner_id),
      :complete => hide_spinner(spinner_id)
    })
  end

#  def cancel_add_menu_item_function(menu_item, button_id)
#    update_page do |page|
#      page.remove dom_id(menu_item)
#    end
#  end

#  def cancel_edit_menu_item_remote_function(menu_item, button_id)
#    remote_function({
#      :url => {:controller => 'groups/menu_items', :action => 'edit', :id => @group.name},
#      :with => %Q['menu_item_id=' + #{menu_item.id}],
#      :loading => spinner_icon_on('pencil', button_id),
#      :complete => spinner_icon_off('pencil', button_id)
#    })
#  end

#  def add_menu_item_button(spinner_id, disabled=false)
#    button_to_remote(I18n.t(:add_button), {
#      :url    => groups_menu_items_url(:action=>'new'),
#      :html   => {:action => groups_menu_items_url(:action=>'new')}, # non-ajax fallback
#      :loading => show_spinner(spinner_id),
#      :loaded => hide_spinner(spinner_id)
#    },
#      :id => 'add_menu_item_button'
#    )
#  end

#  def cancel_menu_item_button(spinner_id)
#    url = groups_menu_items_url(:action=>'update', :_method => :put)
#    button_to_remote I18n.t(:cancel),
#      :url      => url, # same as for the form. Update without data will just reload.
#      :html     => {:action => url}, # non-ajax fallback
#      :update => 'menu_items_list_container',
#      :loading  => show_spinner(spinner_id)
#  end

  def sort_menu_items_js(container_id, spinner_id)
    sortable_element container_id,
        :tag => 'li',
        :handle => 'menu_item_drag_handle',
        :constraint => :vertical,
        :url => sort_widget_menu_items_url(@widget),
        :method => :put,
        :loading => show_spinner(spinner_id),
        :loaded => hide_spinner(spinner_id)
  end
end
