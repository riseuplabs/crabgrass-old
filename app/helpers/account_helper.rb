module AccountHelper
  def required_field_mark
    content_tag :span, "*", :class => "field_required_mark"
  end
end
