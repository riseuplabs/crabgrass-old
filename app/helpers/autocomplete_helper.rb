module AutocompleteHelper

  def autocomplete_entity_tag(field_id, options={})
    options[:url] ||= '/autocomplete/entities'
    options[:onselect] ||= 'null'
    auto_complete_js = %Q[
      new Autocomplete('#{field_id}', {
        serviceUrl:'#{options[:url]}',
        minChars:2,
        maxHeight:400,
        width:300,
        onSelect: #{options[:onselect]},
        rowRenderer: #{render_entity_row_function},
        selectValue: #{extract_value_from_entity_row_function}
      }, #{autocomplete_id_number});
    ]
    javascript_tag(auto_complete_js)
  end

  def autocomplete_users_tag(field_id, options={})
    autocomplete_entity_tag(field_id, options.merge(:url => '/autocomplete/people'))
  end

  private

  def autocomplete_id_number
    rand(100000000)
  end

  # called in order to render a popup row. it is a little too complicated.
  #
  # basically, we want to just highlight the text but not the html tags in the
  # popup row.
  #
  def render_entity_row_function
    %Q[function(value, re, data) {return '<p class=\"name_icon xsmall\" style=\"background-image: url(/avatars/'+data+'/xsmall.jpg)\">' + value.replace(/^<em>(.*)<\\/em>(<br\\/>(.*))?$/gi, function(m, m1, m2, m3){return '<em>' + Autocomplete.highlight(m1,re) + '</em>' + (m3 ? '<br/>' + Autocomplete.highlight(m3, re) : '')}) + '</p>';}]
  end

  # called to convert the row data into a value
  def extract_value_from_entity_row_function
    %Q[function(value){return value.replace(/<em>(.*)<\\/em>.*/g,'$1');}]
  end

end
