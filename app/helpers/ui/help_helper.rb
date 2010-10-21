module UI::HelpHelper

  protected

  def formatting_reference_link
   %Q{<div class='formatting_reference'><a class="small_icon help_16" href="/static/greencloth" onclick="quickRedReference(); return false;">%s</a></div>} % I18n.t(:formatting_reference_link)
  end

  # returns the related help string, but only if it is translated.
  def help(symbol)
    symbol = "#{symbol}_help".to_sym
    text = nil
    begin
      text = I18n.t(symbol)
    rescue I18n::MissingTranslationData
      # this error is only raised in dev/test mode when translation is missing
      return nil
    end

    # return nil if I18n.t can't find the translation (in production mode) and has to humanize it
    text == symbol.to_s.humanize ? nil : text
  end

  def tooltip(caption, content)
    content_tag :span, :class => 'tooltip' do
      content_tag(:span, caption, :class => 'caption') + content_tag(:span, content, :class => 'content')
    end
  end

end

