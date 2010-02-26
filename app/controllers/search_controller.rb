class SearchController < ApplicationController

  prepend_before_filter :login_with_http_auth
  before_filter :login_required, :fetch_user


  # # POST /search/results
  # def results
  #   # redirect to a nice listing
  # end

  # GET /search
  def index
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      render_search_results
    end
  end

  protected

  def redirect_to_search_results
    # delete context information if "Search in this (user|group) only" is unchecked
    path_params = params[:search].clone

    path_params.delete :group if(path_params[:use_group] and path_params[:use_group] != "1")
    path_params.delete :person if(path_params[:use_person] and path_params[:use_person] != "1")

    redirect_to(search_url + parse_filter_path(path_params))
  end

  def render_search_results
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

    full_url = search_url + @path
    handle_rss :title => full_url, :link => full_url,
               :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
  end

  def authorized?
    true
  end

  def fetch_user
    @user ||= current_user
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
      :limit            => 300,        # the max size of the total result
      :around           => 5           # how much text around each match to show. it is not characters. words maybe?
    )
    results.each_with_index do |result, i|
      result.gsub!("{bold}", '<span class="search-excerpt">')
      result.gsub!("{/bold}", '</span>')
      pages[i].flag[:excerpt] = result
    end
  end

end
