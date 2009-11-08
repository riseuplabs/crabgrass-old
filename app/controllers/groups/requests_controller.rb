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
    flash_message_now :success => 'Request to join has been sent'.t
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
      raise ErrorMessage.new('recipient required'.t)
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
        :email => email, :requestable => @group, :language => Gibberish.current_language.to_s)
      begin
        Mailer.deliver_request_to_join_us!(req, mailer_options)
        reqs << req
      rescue Exception => exc
        flash_message_now :text => "#{'Could not deliver email'.t} (#{email}):", :exception => exc
        req.destroy
      end
    end
    if reqs.detect{|req|!req.valid?}
      reqs.each do |req|
        if req.valid?
          flash_message_now :title => 'Error'.t,
            :text => "Success".t + ':',
            :success => 'Invitation sent to {recipient}'[:invite_sent, {:recipient => req.recipient.display_name}]
        else
          flash_message_now :title => 'Error'.t, :object => req
        end
      end
    else
      flash_message_now :success => '{count} invitations sent'[:invites_sent, {:count => reqs.size.to_s }]
      params[:recipients] = ""
    end
  rescue Exception => exc
    flash_message_now :exception => exc
  end

  protected

  def context
    @group_navigation = :requests
    super
    add_context('Requests'[:requests], {:controller => 'groups/requests', :action => :list, :id => @group})
  end

end

