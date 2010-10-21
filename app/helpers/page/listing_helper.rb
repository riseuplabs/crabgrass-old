#
# For showing lists of pages in various ways
#

module Page::ListingHelper

  protected

  ##
  ## COMMON
  ##
  ## helper methods used in all the page listing views
  ##



#  ## used to create the page list headings
#  def page_path_link(text,link_path='',image=nil)
#    hash          = params.dup.to_hash        # hash must not be HashWithIndifferentAccess
#    hash['path']  = @path.merge(link_path)    # we want to preserve the @path class

#    if params[:_context]
#      # special hack for landing pages using the weird dispatcher route.
#      hash = "/%s?path=%s" % [params[:_context], hash[:path].to_s]
#    end
#    link_to text, hash
#  end

#  # *NEWUI
#  #
#  # wrapper for the render :partial call. Options can be the following:
#  # * title
#  # * with_cover :: show cover image
#  # * with_owner :: show owner avatar (default)
#  # * checkable :: add a checkbox for selecting pages
#  # * columns :: info to be displayed in page info box (see below)
#  # * with_notice :: show notifications about that page
#  def list_pages(options)
#    render :partial => '/pages/list', :locals => options
#  end
#  # *NEWUI
#  #
#  # helper to show stars of an item (page or whatever that responds to stars_count)
#  #
#  def stars_for(item)
#    if item.stars_count > 0
#      content_tag(:span, "%s %s" % [icon_tag('star'), item.stars_count], :class => 'star')
#    else
#      icon_tag('star_empty')
#    end
#  end

#  # *NEWUI
#  #
#  # render the cover of the page if it exists
#  #
#  def cover_for(page)
#    thumbnail_img_tag(page.cover, :medium, :scale => '96x96') if page.cover
#  end

#  # *NEWUI
#  #
#  # helper to show the information box of a page
#  #
#  def page_information_box_for(page, options={})
#    locals = {:page => page}

#    # status, date and username
#    field    = (page.updated_at > page.created_at + 1.hour) ? 'updated_at' : 'created_at'
#    is_new = field == 'updated_at'
#    status    = is_new ? I18n.t(:page_list_heading_updated) : I18n.t(:page_list_heading_new)
#    username = link_to_user(page.updated_by_login)
#    date     = friendly_date(page.send(field))
#    locals.merge!(:status => status, :username => username, :date => date)

#    if options.has_key?(:columns)
#      locals.merge!(:views_count => page.views_count) if options[:columns].include?(:views)
#      if options[:columns].include?(:stars)
#        star_icon = page.stars_count > 0 ? icon_tag('star') : icon_tag('star_empty')
#        locals.merge!(:stars_count => content_tag(:span, "%s %s" % [star_icon, page.stars_count]))
#      end
#      locals.merge!(:contributors =>  content_tag(:span, "%s %s" % [image_tag('ui/person-dark.png'), page.stars_count])) if options[:columns].include?(:contributors)
#    end

#    render :partial => 'pages/information_box', :locals => locals
#  end




#  # *NEWUI
#  #
#  #
#  #
#  def title_with_link_for(page, participation = nil)
#    title = link_to(h(page.title), page_url(page))

#    # this is not used for now
#    #if participation and participation.instance_of? UserParticipation
#    #  title += " " + icon_tag("tiny_star") if participation.star?
#    #else
#    #  #title += " " + icon_tag("tiny_pending") unless page.resolved?
#    #end
#    #if page.flag[:new]
#    #  title += " <span class='newpage'>#{I18n.t(:page_list_heading_new)}</span>"
#    #end
#    return title
#  end


#  # *NEWUI
#  #
#  #
#  # The list partial hands all local vars down to the page partial
#  # that are in the list of allowed locals.
#  def page_locals(locals)
#    allowed_locals = [:columns, :checkable, :with_cover, :with_owner, :with_notice, :with_tooltip]
#    locals.reject { |key,_| !allowed_locals.include? key }
#  end


#  # allow bold in the excerpt, but no other html. We use special {bold} for bold.
#  def escape_excerpt(str)
#    h(str).gsub /\{(\/?)bold\}/, '<\1b>'
#  end

#  def page_tags(page=@page, join=nil)
#    join ||= "\n" if join.nil?
#    if page.tags.any?
#      links = page.tags.collect do |tag|
#        tag_link(tag, page.owner)
#      end
#      links = (join != false) ? links.join(join) : links
#    end
#  end

#  #
#  # Often when you run a page search, you will get an array of UserParticipation
#  # or GroupParticipation objects.
#  #
#  # This method will convert the array to Pages if they are not.
#  #
#  def array_of_pages(pages)
#    if pages
#      if pages.first.is_a? Page
#        return pages
#      else
#        return pages.collect{|p|p.page}
#      end
#    end
#  end

#  #
#  # Sometimes we want to divide a list of time ordered +pages+
#  # into several collections by recency.
#  #
#  # def divide_pages_by_recency(pages)
#  #   today = []; yesterday = []; week = []; later = [];
#  #   pages = array_of_pages(pages).dup
#  #   page = pages.shift
#  #   while page and after_day_start?(page.updated_at)
#  #     today << page
#  #     page = pages.shift
#  #   end
#  #   while page and after_yesterday_start?(page.updated_at)
#  #     yesterday << page
#  #     page = pages.shift
#  #   end
#  #   while page and after_week_start?(page.updated_at)
#  #     week << page
#  #     page = pages.shift
#  #   end
#  #   # unless today.size + yesterday.size + week.size > 0
#  #   #   show_time_dividers = false
#  #   # else
#  #   while page
#  #     later << page
#  #     page = pages.shift
#  #   end
#  #   # end
#  #
#  #   return today, yesterday, week, later
#  # end

end

