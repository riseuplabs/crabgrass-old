class NetworkController < GroupController

  def initialize(options={})
    super()
    @group = options[:group] # the group context, if any
  end

  def show
    super
    @group_pages = Page.find_by_path(['descending', 'updated_at', 'limit','10'], options_for_groups(@group.group_ids))
  end

  protected
  
  def context
    network_context
    unless action?(:show)
      add_context params[:action], network_url(:action => params[:action], :id => @group, :path => params[:path])
    end
  end

end
