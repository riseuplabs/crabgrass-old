class MessagePageController < BasePageController

  def show
    @comment_header = ""
  end

  def create
    if request.post?
      users = params[:to].split(/\s+/).uniq.collect do |name|
        User.find_by_login name
      end.compact

      return flash_message_now(:error => 'subject must not be empty'.t) unless params[:title].any?
      return flash_message_now(:error => 'at least one recipient is required'.t) unless users.any?
      return flash_message_now(:error => 'message must not be empty'.t) unless params[:message].any?

      @page = Page.make_a_call :private_message, :to => users, :from => current_user, :title => params[:title], :body => params[:message]
      if params[:email]
        @page.users.each do |u|
          Mailer.deliver_share_notice(u, 'new personal message', mailer_options) if current_user != u
        end
      end

      return flash_message_now(:object => @page.discussion.posts.first) unless @page.discussion.posts.first.valid?
      return flash_message_now(:object => @page.discussion) unless @page.discussion.valid?
      return flash_message_now(:object => @page) unless @page.valid?

      redirect_to page_url(@page)
    end
  end

  protected

  def setup_view
    @show_reply = true
    @show_attach = true
  end

end
