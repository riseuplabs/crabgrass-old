class BasePage::TagsController < BasePage::SidebarController

  before_filter :login_required
  helper 'base_page/tags'

  def show
    render :partial => 'base_page/tags/popup'
  end

  def update
    if params[:close]
      render :template => 'base_page/reset_sidebar'
      return
    elsif params[:add]
      @page.tag_list.add(params[:add], :parse => true)
      @page.updated_by = current_user
      @page.save
      render :template => 'base_page/reset_sidebar'
    elsif params[:remove]
      @page.tag_list.remove(params[:remove])
      @page.updated_by = current_user
      @page.save
      render :nothing => true
    end
  end

  protected

end
