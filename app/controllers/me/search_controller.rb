class Me::SearchController < Me::BaseController

  prepend_before_filter :login_with_http_auth

  def index
    if request.post?
      redirect_to( me_url(:action => 'search') + parse_filter_path(params[:search]) )
    else
      @path.default_sort('updated_at') if @path.search_text.empty?
      @pages = Page.paginate_by_path(@path, options_for_me(:method => :sphinx, :page => params[:page]))

      # if there was a text string in the search, generate extracts for the results
      if @path.search_text and @pages.any?
        begin
          add_excerpts_to_pages(@pages)
        rescue Errno::ECONNREFUSED, Riddle::VersionError, Riddle::ResponseError => err
          RAILS_DEFAULT_LOGGER.warn "failed to extract keywords from sphinx search: #{err}."
        end
      end

      if @path.sort_arg?('created_at') or @path.sort_arg?('created_by_login')
        @columns = [:icon, :title, :owner, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :owner, :updated_by, :updated_at, :contributors_count]
      end
      full_url = me_url(:action => 'search') + @path
      handle_rss :title => full_url, :link => full_url,
                 :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    end
  end

  protected

  def context
    super
    add_context I18n.t(:me_search_link), url_for(:controller => '/me/search', :action => nil, :path => params[:path])
  end

  def add_excerpts_to_pages(pages)
    config = ThinkingSphinx::Configuration.instance
    client = Riddle::Client.new config.address, config.port

    results = client.excerpts(
      :docs             => pages.collect {|page| page.page_terms ? page.page_terms.body : ""},
      :words            => @path.search_text,
      :index            => "page_terms_core",
      :before_match     => "{bold}",
      :after_match      => "{/bold}",
      :chunk_separator  => " ... ",
      :limit            => 400,        # the max size of the total result
      :around           => 5           # how much text around each match to show. it is not characters. words maybe?
    )
    results.each_with_index do |result, i|
      pages[i].flag[:excerpt] = result
    end
  end

end
