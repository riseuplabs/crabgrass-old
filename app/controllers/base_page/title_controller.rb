class BasePage::TitleController < BasePage::SidebarController

  before_filter :login_required

  # return the edit title form
  def edit
  end

  def update
    if params[:save]
      @old_name = @page.name
      @page.title   = params[:page][:title]
      @page.summary = params[:page][:summary]
      @page.name    = params[:page][:name].to_s.nameize if params[:page][:name].any?
      @page.updated_by = current_user
      @new_name = @page.name
      unless @page.save
        ## TODO: make this the automatic behavior on errors when modalbox is open.
        render :update do |page|
          page.replace('modal_message', message_text(:object => @page))
          page << hide_spinner('save_title')
          page.select('submit').each do |submit|
            submit.disable = false
          end
        end
        return
      end
    end
    render :template => 'base_page/title/update_title'
  end

  protected

end
