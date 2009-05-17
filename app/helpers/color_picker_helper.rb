module ColorPickerHelper
  def include_color_picker
    return if @color_picker_included
    @color_picker_included = true
    content_for :html_head do
      output = []
      output << javascript_include_tag("colorpicker/yahoo.color.js")
      output << javascript_include_tag("colorpicker/colorpicker.js")
      output << stylesheet_link_tag("colorpicker/colorpicker.css")
      output * "\n"
    end
  end
  
  def color_picker_tag(input_id)
    # TODO: add {swatch: button} option
    include_color_picker
    javascript_tag(%Q[new Control.ColorPicker("#{input_id}", { IMAGE_BASE : "/images/colorpicker/" })])
  end
end