module SearchHelper
  def mini_search_text_field_tag
    text_field_tag('search[text]', '', :class => 'text',
                                      :value => I18n.t(:search_input_caption),
                                      :onfocus => hide_default_value,
                                      :onblur => show_default_value)
  end
end
