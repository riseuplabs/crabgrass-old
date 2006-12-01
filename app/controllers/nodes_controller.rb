class NodesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @node_pages, @nodes = paginate :nodes, :per_page => 10
  end

  def show
    @node = Node.find(params[:id])
  end

  def new
    @node = Node.new
  end

  def create
    @node = Node.new(params[:node])
    if @node.save
      flash[:notice] = 'Node was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @node = Node.find(params[:id])
  end

  def update
    @node = Node.find(params[:id])
    if @node.update_attributes(params[:node])
      flash[:notice] = 'Node was successfully updated.'
      redirect_to :action => 'show', :id => @node
    else
      render :action => 'edit'
    end
  end

  def destroy
    Node.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
