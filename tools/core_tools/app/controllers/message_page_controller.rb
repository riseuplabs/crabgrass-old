class MessagePageController < BasePageController

  def show
    @comment_header = ""
  end

  def create
    if request.post?
      users = params[:to].split(/\s+/).uniq.collect do |name|
        User.find_by_login name
      end.compact

      return flash_message_now(:error => I18n.t(:subject_must_not_be_empty)) unless params[:title].any?
      return flash_message_now(:error => I18n.t(:at_least_one_recipient_is_required)) unless users.any?
      return flash_message_now(:error => I18n.t(:message_must_not_be_empty)) unless params[:message].any?

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
