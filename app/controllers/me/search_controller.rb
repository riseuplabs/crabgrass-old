class Me::SearchController < Me::BaseController

  prepend_before_filter :login_with_http_auth
  
  def index
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to me_url(:action => 'search') + path   
    else
      @pages = Page.paginate_by_path(params[:path], options_for_me(:method => :sphinx, :page => params[:page]))
      
      # if there was a text string in the search, generate extracts for the results      
      if parsed_path.keyword? 'text' and @pages.any?
        begin
          add_excerpts_to_pages(@pages)
        rescue Errno::ECONNREFUSED, Riddle::VersionError, Riddle::ResponseError => err
          RAILS_DEFAULT_LOGGER.warn "failed to extract keywords from sphinx search: #{err}."
        end
      end
      
      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
        @columns = [:icon, :title, :group, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors_count]
      end
      full_url = me_url(:action => 'search') + '/' + String(parsed_path)
      handle_rss :title => full_url, :link => full_url,
                 :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    end
  end
    
  protected

  # it is impossible to see anyone else's me page,
  # so no authorization is needed.
  def authorized?
    return true
  end
  
  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('large')
    add_context 'Search'[:me_search_link], url_for(:controller => '/me/search', :action => nil, :path => params[:path])
  end

  def add_excerpts_to_pages(pages)
    config = ThinkingSphinx::Configuration.new
    client = Riddle::Client.new config.address, config.port

    results = client.excerpts(
      :docs             => pages.collect {|page| page.page_terms ? page.page_terms.body : ""},
      :words            => parsed_path.search_text,
      :index            => "page_terms_core",
      :before_match     => "<b>",
      :after_match      => "</b>",
      :chunk_separator  => " ... ",
      :limit            => 400,
      :around           => 20
    )
    results.each_with_index do |result, i|
      pages[i].flag[:excerpt] = result
    end
  end
    
end

