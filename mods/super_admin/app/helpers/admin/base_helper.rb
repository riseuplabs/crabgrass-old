module Admin::BaseHelper
  def flash_notice
    "<div class='errorExplanation'>#{flash[:notice]}</div>" if flash[:notice]
  end

  def alphabetical_filter url_options
    links = []
    (('A'..'Z').to_a+['#']).each do |letter|
      links << link_to(letter, url_options.merge(:filter => letter))
    end
    links << link_to("ALL", url_options)
    content_tag(:span, links.join('&nbsp;'), :class => 'alphabetical_filter')
  end
end

