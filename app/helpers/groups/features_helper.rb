module Groups::FeaturesHelper

  def autocomplete_service_url
    "/groups/features/auto_complete/" + @group.name
  end

  def autocomplete_item_selected_function(autocomplete_id)
    function_code = remote_function({
      :url => {:controller => 'groups/features', :action => 'create', :id => @group.name},
      :with => %{'page_id=' + data},
      :update => 'features_list_container',
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
        message:'#{I18n.t(:enter_page_title)}...',
        width:400,
        onSelect: #{autocomplete_item_selected_function(autocomplete_id)},
      }, '#{autocomplete_id}');
    ]
  end

  def destroy_feature_remote_function(feature, button_id)
    remote_function({
      :url => {:controller => 'groups/features', :action => 'destroy', :id => @group.name},
      :with => %Q['feature_id=' + #{feature.id}],
      :method => :delete,
      :update => 'features_list_container',
      :loading => spinner_icon_on('minus', button_id),
      :complete => spinner_icon_off('minus', button_id)
    })
  end

  def handle_update_feature_order_javascript(container_id, spinner_id)
    # require 'ruby-debug';debugger;1-1
    sortable_element container_id,
        :tag => 'tr',
        :handle => 'feature_drag_handle',
        :ghosting => true,
        :constraint => :vertical,
        :url => { :controller => 'groups/features', :action => 'update', :id => @group.name},
        :update => 'features_list_container',
        :method => :put,
        :loading => show_spinner(spinner_id),
        :loaded => hide_spinner(spinner_id)
    end
end
