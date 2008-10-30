class ArticlePageController < WikiPageController

  def create
    @page_class = ArticlePage
    @stylesheet = 'page_creation'
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        @page = create_new_page!(@page_class)
        if params[:asset][:uploaded_data].any?
          @asset = Asset.make!(params[:asset].merge(:parent_page => @page))
          image_tag = "!<%s!:%s" % [@asset.thumbnail(:medium).url,@asset.url]
        end
        body = "%s\n\n%s" % [image_tag, params[:body]]
        @wiki = Wiki.create!(:user => current_user, :body => body)
        @page.update_attribute(:data, @wiki)
        redirect_to(page_url(@page))
      rescue Exception => exc
        @wiki.destroy if @wiki
        @asset.destroy if @asset
        @page = exc.record if exc.record.is_a? Page
        flash_message_now :exception => exc
      end
    end
  end

end
