module MenuItemsHelper

  def form_remote_for_menu_item(menu_item)
    if menu_item.new_record?
      locals = { :spinner_id => 'add_menu_item_spinner',
        :submit_title => I18n.t(:add_button),
      }
    else
      locals = { :spinner_id => dom_id(menu_item, :save_button),
        :submit_title => I18n.t(:save_button),
      }
    end

    locals.merge! :menu_item => menu_item,
      :form_options => { :loading => show_spinner(locals[:spinner_id]) }
    render :partial => '/menu_items/form', :locals => locals
  end

  def edit_menu_item_link(menu_item)
    if menu_item.may_have_children?
      link_to_modal(I18n.t(:edit),
        :title => menu_item.title,
        :url => edit_widget_menu_item_url(@widget, menu_item))
    else
      toggle_object_display(I18n.t(:edit), menu_item, :list, :form)
    end
  end

  def toggle_object_display(body, object, *symbols)
    link_to_function(body, nil) do |page|
      symbols.each do |sym|
        page.toggle dom_id(object, sym)
      end
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
