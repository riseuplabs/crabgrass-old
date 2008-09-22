class CollectionController < BasePageController

  ##
  ## ACCESS: no restriction
  ##

  def create
    @page_class = Collection
    if request.post?
      return redirect_to(create_page_url) if params[:cancel]
      begin
        @page = create_new_page!(@page_class)
        redirect_to(page_url(@page, :action => 'edit'))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
      end
    end
  end

  ##
  ## ACCESS: public or :view
  ##

  def show
    @pages = @page.pages
  end

=begin

I guess these aren't applicable to colletions

  def version
  end

  def versions
  end
  
  def diff
  end
=end

  def print
    @pages = @page.pages
    render :layout => "printer-friendly"
  end

  ##
  ## ACCESS: :edit
  ##

  def edit
    @pages = @page.pages
    if params[:cancel]
      cancel
    elsif request.post? and params[:save]
      save
    end

  end

  protected

  def save
    if @page.save
      redirect_to page_url(@page, :action => 'show')
    else
      flash_message_now :object => @page
    end
  end

  def cancel
    redirect_to page_url(@page, :action => 'show')
  end

  def authorized?
    if @page
      if %w(show print diff version versions).include? params[:action]
        @page.public? or current_user.may?(:view, @page)
      elsif %w(edit break_lock).include? params[:action]
        current_user.may?(:edit, @page)
      else
        current_user.may?(:admin, @page)
      end
    else
      true
    end
  end

end
