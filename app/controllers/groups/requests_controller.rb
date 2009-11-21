class Groups::RequestsController < Groups::BaseController

  helper 'requests'
  permissions 'groups/requests', 'requests'
  before_filter :fetch_group
  before_filter :login_required

  def list
    params[:state] ||= 'pending'

    @incoming = Request.to_group(@group).having_state(params[:state]).by_created_at.paginate(:page => params[:in_page])

    @outgoing = Request.from_group(@group).appearing_as_state(params[:state]).by_created_at.paginate(:page => params[:out_page])

    # hide ignored states
    # @outgoing.each {|r| r.state = 'pending'} if params[:state] == 'pending'
    # ^^^ what the hell was this supposed to do? -e
  end

  ##
  ## CREATION
  ##

  def create_join
    if request.get?
      store_back_url and return
    else
      redirect_to url_for_group(@group) and return unless params[:send]
    end

    RequestToJoinYou.create! :created_by => current_user, :recipient => @group
    flash_message_now :success => I18n.t(:request_to_join_sent)
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  def create_invite
    if request.get?
      store_back_url and return
    else
      redirect_to url_for_group(@group) unless params[:send]
    end

    users, groups, emails = Page.parse_recipients!(params[:recipients])
    groups = [] unless @group.network?

    reqs = []; mailers = []
    unless users.any? or emails.any? or groups.any?
      raise ErrorMessage.new(I18n.t(:recipient_required))
    end
    users.each do |user|
      if params[:email_all]
        emails << user.email
      else
        reqs << RequestToJoinUs.create(:created_by => current_user,
          :recipient => user, :requestable => @group)
      end
    end
    groups.each do |group|
      reqs << RequestToJoinOurNetwork.create(:created_by=>current_user,
        :recipient => group, :requestable => @group)
    end
    emails.each do |email|
      req = RequestToJoinUsViaEmail.create(:created_by => current_user,
        :email => email, :requestable => @group, :language => I18n.locale.to_s)
      begin
        Mailer.deliver_request_to_join_us!(req, mailer_options)
        reqs << req
      rescue Exception => exc
        flash_message_now :text => "#{I18n.t(:could_not_deliver_email)} (#{email}):", :exception => exc
        req.destroy
      end
    end
    if reqs.detect{|req|!req.valid?}
      reqs.each do |req|
        if req.valid?
          flash_message_now :title => I18n.t(:alert_error),
            :text => I18n.t(:success) + ':',
            :success => I18n.t(:invite_sent, :recipient => req.recipient.display_name)
        else
          flash_message_now :title => I18n.t(:alert_error), :object => req
        end
      end
    else
      flash_message_now :success => I18n.t(:invites_sent, :count => reqs.size.to_s)
      params[:recipients] = ""
    end
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  # create a request to destroy (aka a destroy proposal)
  def create_destroy

    redirect_to url_for_group(@group)
  end

  protected

  def context
    @group_navigation = :requests
    super
    add_context(I18n.t(:requests), {:controller => 'groups/requests', :action => :list, :id => @group})
  end

end

