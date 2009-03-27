module ControllerExtension::WikiRenderer

  include ControllerExtension::ContextParser

  protected

  def render_wiki_html(body, context_name)
    context_name ||= 'page'
    greencloth = GreenCloth.new(body)
    # surround each section in divs
    greencloth.wrap_section_html = true

    greencloth.to_html do |link_data|
      if link_data[:auto]
        generate_wiki_auto_link(link_data[:url])
      elsif link_data[:page]
        generate_wiki_page_link(link_data[:label], (link_data[:context]||context_name), link_data[:page], link_data[:anchor])
        nil # default link
      end
    end
  end

  # each section in the html could be locked or editable for +user+
  # this method adds correct links to edit each section
  # later it could add other dynamic per-user things
  def generate_wiki_html_for_user(wiki, user)
    html = wiki.body_html

    return html unless user.may?(:edit, wiki.page)

    html_sections = html.index_split(/<div\s*class\s*=\s*['"]wiki_section/)

    output_html = ""
    html_sections.each do |section|
      start_div_re = /(<div\s*class="wiki_section"\s*id="wiki_section-(\d+)">)/
      # replace the start div with (itself + edit link)
      section_with_link = section.sub(start_div_re) do
        existing_div = $1
        section_index = $2.to_i

        link_html = section_edit_tag(wiki, user, section_index)

        existing_div + "\n  " + link_html
      end
      output_html << section_with_link
    end
    return output_html
  end

  # create a link to edit this section for the user
  # unless the section is locked
  def section_edit_tag(wiki, user, section_index)
    html = "<div class=\"editsection\" id=\"editsection-#{section_index}\">"
    if wiki.editable_by?(user, section_index)
      label = image_tag("actions/pencil.png") + "edit section"
      html << content_tag(:a, label, :href => page_url(wiki.page, :action => 'edit', :section => section_index))
    else
      # must be unlocked
      locker_id = wiki.locked_by_id(section_index)
      locker = User.find(locker_id)
      label = image_tag("png/16/lock.png") + "break lock by #{locker.display_name}"
      html << content_tag(:a, label, :href => page_url(wiki.page, :action => 'edit', :section => section_index))
    end
    html << "</div>"
  end
  
  private
  
  #
  # handle auto links
  #
  # if the url matches the domain of this website, 
  # then convert the auto link into a wiki link by looking up the page.
  #
  # TODO: it would be better to cleanup the raw greencloth markup instead of
  # just the rendered html.
  #
  def generate_wiki_auto_link(url)
    exp = /^https?:\/\/#{Regexp.escape(request.host_with_port)}\//
    if url =~ exp      
      path_without_domain = url.sub(exp,'')
      path_elements = path_without_domain.split('/')
      if path_elements.size == 2
        context_name, page_name = path_elements
        begin
          entity, page = resolve_context(context_name, page_name)
          content_tag :a, page.title, :href => page_url(page)
        rescue ActiveRecord::RecordNotFound => exc
          # not found
          return nil 
        end
      else
        nil
      end
    else
      nil
    end
  end
  
  # generates an <a> tag from the a wiki link to a page, like these:
  #
  #  [ blah -> group/wiki_name ]
  #  [ wiki_name ]
  #  [ blah -> wiki_name ]
  #
  def generate_wiki_page_link(label, context_name, page_name, anchor)
    begin
      entity, page = resolve_context(context_name, page_name)
      label ||= page.title
      content_tag :a, label, :href => page_url(page) + anchor
    rescue ActiveRecord::RecordNotFound => exc
      # not found
      label ||= page_name.nameized? ? page_name.denameize : page_name
      label = html_escape(label)
      url = '/%s/%s' % [context_name.nameize, page_name.nameize]
      content_tag :a, label, :href => url, :class => 'dead_link'
    end
  end
end

