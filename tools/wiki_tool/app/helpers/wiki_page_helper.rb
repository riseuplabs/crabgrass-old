module WikiPageHelper

  def may_destroy_wiki_version?
    current_user.may?(:admin, @page)
  end

  def may_revert_wiki_version?
    current_user.may?(:edit, @page)
  end

  def locked_error_message
    if locked_for_me?
      user_id = @wiki.locker_of(:document).id
      user = User.find_by_id user_id
      display_name = user ? user.display_name : 'unknown'
      msgs = [
        'This wiki is currently locked by :user'[:wiki_locked] % {:user => display_name},
        'You will not be able to save this page'[:wont_be_able_to_save]
      ]
      flash_message_now :title => 'Page Locked'[:page_locked_header], :error => msgs
    end
  end

  def load_lasted_change_diff
   javascript_tag(
     remote_function(
       :update => 'wiki_html',
       :url => page_xurl(@page, :action => 'diff', :controller => 'version', :id => ("%d-%d" % [@last_seen.version, @wiki.version]))
     )
   )
  end

  def locked_for_me?(section = :document)
    if @wiki and logged_in?
      @wiki.section_locked_for?(section, current_user)
    else
      false
    end
  end

  ### TODO: cache all greencloth html using the cache helper
  def wiki_body_html(wiki = @wiki)
    html = wiki.body_html
    doc = Hpricot(html)
    doc.search('h1 a.anchor, h2 a.anchor, h3 a.anchor, h4 a.anchor').each do |heading_el|
      section = heading_el['href'].sub(/^.*#/, '')

      link_opts = {:url => page_url(@page, :action => 'edit', :section => section)}
      if editing_a_section?
        link_opts[:confirm] = "Any unsaved text will be lost. Are you sure?"[:wiki_lost_text_confirmation]
      end
      link = link_to_remote_icon('pencil', link_opts, :class => 'edit', :title => 'Edit This Section'[:wiki_section_edit], :id => "#{section}_edit_link")
      heading_el.parent.insert_after(Hpricot(link), heading_el)
    end
    doc.to_html
  end

  def wiki_body_html_with_edit_form(wiki = @wiki, section = @editing_section)
    html = wiki_body_html(wiki).dup

    return html unless editing_a_section?

    markup_to_edit = wiki.get_body_for_section(section)

    inline_form = render_inline_form(markup_to_edit, section)
    inline_form << "\n"

    # replace section html with the form
    # and return the modified html
    doc = Hpricot(html)
    doc.at("a[@name=#{section}]").parent.swap(inline_form)
    doc.to_html
  end

  def render_inline_form(markup, section)
    render :partial => 'edit_inline', :locals => {:markup => markup, :section => section}
  end


  # def replace_section_with_form(html, section, form)
  #    doc =
  #
  #    return doc.to_html
  #  end



  #
  # def wiki_html_cache_key(wiki = @wiki)
  #   cache_key("wikis/html", :_id => @wiki.id, :body_hash => @wiki.body.to_s,
  #               :may_edit_page => may_edit_page?, :editing_a_section => editing_a_section?,
  #               # page url keys on page owner changes (which might change links as well )
  #               :page_url => page_url(@page))
  # end


  # # use javascript to add edit links to each section heading
  # # solves the problem of some user's not having edit permissions
  # def decorate_with_edit_links
    #
    # opts = {:url => url}
    #
    # if editing_a_section?
    #   opts[:confirm] = "Any unsaved text will be lost. Are you sure?"[:wiki_lost_text_confirmation]
    # end
    #
    # link = link_to_remote_icon('pencil', opts, :class => 'edit', :title => 'Edit This Section'[:wiki_section_edit], :id => '_change_me__edit_link')
    # link.gsub!('"','\"')
    #
    # javascript_tag %Q[decorate_wiki_edit_links("#{link}")]
  # end

  # returns the body html, but with a form in the place of the named heading
  def body_html_with_form(wiki, section = :document)
    body_html = wiki.body_html.dup
    return body_html if section == :document

    greencloth = GreenCloth.new(wiki.body)
    text_to_edit = greencloth.get_text_for_heading(section)

    form << "\n"
    next_heading = greencloth.heading_tree.successor(section)
    next_heading = next_heading ? next_heading.name : nil
    html = replace_section_with_form(html, section, next_heading, form)

    html
  end


end

