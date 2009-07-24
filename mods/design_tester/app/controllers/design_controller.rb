=begin

  Just for testing the layouts

=end

class DesignController < ApplicationController

  layout 'design'
  helper 'base_page'
  before_filter :fetch_random_data, :fetch_site
  #stylesheet 'post'
  stylesheet 'gallery'
  stylesheet 'contribute'

  def index
    data = params[:data]
    if data
      @main_column  = read_file(data, 'main')
      @left_column  = read_file(data, 'left')
      @right_column = read_file(data, 'right')
      @banner       = read_file(data, 'banner')
      @footer       = read_file(data, 'footer')
      @title_box    = read_file(data, 'title_box')
      @info_box    = read_file(data, 'info_box')

      @banner       ||= read_file('default', 'banner')
      @footer       ||= read_file('default', 'footer')
      @main_column  ||= read_file('default', 'main_column')
      @title_box    ||= read_file('default', 'title_box')
    else
     @main_column = 'click on a tab'
    end
  end

  def dummy_check
    sleep 1
    render :nothing => true
  end

  protected

  def fetch_random_data
    if User.count > 0
      begin
        @user = User.find_by_id rand(User.count)
      end while @user.nil?
    end
    if Page.count > 0
      begin
        @page = Page.find_by_id rand(Page.count)
      end while @page.nil?
    end
  end

  def read_file(dir, file)
    filename = "design/#{dir}/#{file}"
    app_base = File.dirname(File.dirname(__FILE__))
    if File.exists? "#{app_base}/views/#{filename}.html.erb"
      return render_to_string(:file => "#{app_base}/views/#{filename}.html.erb")
    else
      return nil
    end
  end

  def fetch_site
    @site = Site.default
  end

end
