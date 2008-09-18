class NetworkController < GroupController

  def initialize(options={})
    super()
    @group = options[:group] # the group context, if any
  end

  protected
  
  def context
    network_context
    add_context params[:action], network_url(:action => params[:action], :id => @group, :path => params[:path])
  end

end
