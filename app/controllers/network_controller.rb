class NetworkController < GroupController

  def initialize(options={})
    super(options)
  end

  def show
    super
    if @group
      # there might not be @group if the profile is hidden
      @group_pages = Page.find_by_path(['descending', 'updated_at', 'limit','10'], options_for_groups(@group.group_ids))
    end
  end

  protected
  
  def context
    network_context
    unless action?(:show)
      add_context params[:action], network_url(:action => params[:action], :id => @group, :path => params[:path])
    end
  end

end
