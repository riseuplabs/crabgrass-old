##
## Theme Helper -- a mixin for ActionView::Base
##

module Crabgrass::Theme::Helper
  def theme_render(value)
    return unless value
    if value.is_a? Proc
      self.instance_eval &value
    elsif value.is_a? Hash
      render value
    elsif value.is_a? String
      value
    end
  end
end

