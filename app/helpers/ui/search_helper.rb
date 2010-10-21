module UI::SearchHelper

  def mini_search_text_field_tag
    text_field_tag('search[text]', '', :class => 'text',
                                      :size => 17,
                                      :value => I18n.t(:search_input_caption),
                                      :onfocus => hide_default_value,
                                      :onblur => show_default_value)
  end

  def mini_search_form(options={})
    unless params[:action] == 'search' or params[:controller] =~ /search|inbox/
      render :partial => 'pages/mini_search', :locals => options
    end
  end

end
