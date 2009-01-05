module ControllerExtension::WikiRenderer

  include ControllerExtension::ContextParser

  protected

  def render_wiki_html(body, context_name)
    context_name ||= 'page'
    GreenCloth.new(body).to_html do |link_data|
      if link_data[:auto]
        generate_wiki_auto_link(link_data[:url])
      elsif link_data[:page]
        generate_wiki_page_link(link_data[:label], (link_data[:context]||context_name), link_data[:page])
      else
        nil # default link
      end
    end
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
  def generate_wiki_page_link(label, context_name, page_name)
    begin
      entity, page = resolve_context(context_name, page_name)
      label ||= page.title
      content_tag :a, label, :href => page_url(page)
    rescue ActiveRecord::RecordNotFound => exc
      # not found
      label ||= page_name.nameized? ? page_name.denameize : page_name
      label = html_escape(label)
      url = '/%s/%s' % [context_name.nameize, page_name.nameize]
      content_tag :a, label, :href => url, :class => 'dead_link'
    end
  end

end

