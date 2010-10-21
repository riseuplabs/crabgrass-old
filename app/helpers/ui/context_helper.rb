##
## DISPLAYING CONTEXT
##
## see context.rb for more information
##

module UI::ContextHelper

  def link_to_breadcrumbs
  #  if @breadcrumbs and @breadcrumbs.length >= breadcrumb_min_length
  #    content_tag(:section, @breadcrumbs.collect{|b| content_tag(:a, b[0], :href => b[1])}.join(' &raquo; '), :class => 'breadcrumb')
  #  else
      ""
  #  end
  end

  #def first_breadcrumb
  #  @breadcrumbs.first.first if @breadcrumbs.any?
  #end

  #def breadcrumb_min_length
  #  controller?(:search) ? 2 : 3
  #end

  ##
  ## TITLE
  ##

  def context_titles
    return [] unless @context
    @context.breadcrumbs.collect do |i|
      truncate( crumb_to_s(i) )
    end.reverse
  end

  private

  def crumb_to_s(crumb)
    if crumb.is_a? Array
      crumb[0].to_s
    elsif crumb.respond_to? :display_name
      crumb.display_name
    else
      crumb.to_s
    end
  end

end
