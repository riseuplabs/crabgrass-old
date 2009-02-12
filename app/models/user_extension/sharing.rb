=begin

A user's relationship to pages

=end

module UserExtension::Sharing

  ##
  ## ASSOCIATIONS
  ##

  def self.included(base)
    base.instance_eval do
      has_many :participations, :class_name => 'UserParticipation', 
        :after_add => :update_tag_cache, :after_remove => :update_tag_cache,
        :dependent => :destroy
      has_many :pages, :through => :participations do
        def pending
          find(:all, :conditions => ['resolved = ?',false], :order => 'happens_at' )
        end
      end
      
      #has_many :pages_created,
      #  :class_name => "Page", :foreign_key => :created_by_id 

      #has_many :pages_updated, 
      #  :class_name => "Page", :foreign_key => :updated_by_id   
    end
  end

  ##
  ## USER PARTICIPATIONS
  ##

  # makes or updates a user_participation object for a page.
  # returns the user_participation, which must be saved for changed
  # to take effect
  #
  # this method is not called directly. instead, page.add(user)
  # should be used.
  #
  # TODO: delete the user_participation row if it is not really needed
  # anymore (ie, the user won't lose access by deleted it, and inbox,
  # watch, star are all false, and the user has not contributed.)
  def add_page(page, part_attrs)
    clear_access_cache
    part_attrs = part_attrs.dup
    part_attrs[:notice] = [part_attrs[:notice]] if part_attrs[:notice]
    participation = page.participation_for_user(self)
    if participation
      self.update_participation(participation, part_attrs)
    else
      participation = self.build_participation(page, part_attrs)
    end  
    page.association_will_change(:users)
    participation
  end

  ## called only by add_page
  def update_participation(participation, part_attrs)
    if part_attrs[:notice]        
      part_attrs[:viewed] = false
      if participation.notice
        if repeat_notice?(participation.notice, part_attrs[:notice])
          part_attrs[:notice] = participation.notice # don't repeat
        else
          part_attrs[:notice] += participation.notice
        end
      end
    end
    participation.attributes = part_attrs
  end
  ## called only by update_participation
  def repeat_notice?(current_notices, new_notice)
    new_notice = new_notice.first
    current_notices.detect do |notice|
      notice[:message] == new_notice[:message] and notice[:user_login] == new_notice[:user_login]
    end
  end
  ## called only by add_page
  def build_participation(page, part_attrs)
    # user_participations.build doesn't update the pages.users
    # until it is saved. If you need an updated users list, then
    # use user_participations directly.
    page.user_participations.build(part_attrs.merge(
      :page_id => page.id, :user_id => id,
      :resolved => page.resolved?))
  end

  # remove self from the page.
  # only call by page.remove(user)    
  def remove_page(page)
    clear_access_cache
    page.users.delete(self)
    page.updated_by_id_will_change!
    page.association_will_change(:users)
    page.user_participations.reset
  end
     
  # set resolved status vis-à-vis self.
  def resolved(page, resolved_flag)
    find_or_build_participation(page).update_attributes :resolved => resolved_flag
  end
  
  def find_or_build_participation(page)
    page.participation_for_user(self) || page.user_participations.build(:user_id => self.id) 
  end
  
  # This should be called when a user modifies a page and that modification
  # should trigger a notification to page watchers. Also, if a page state changes
  # from pending to resolved, we also update everyone's user participation.
  # The page is not saved here, because it might still get more changes.
  # An after_filter should finally save the page if it has not already been saved.
  #
  # options:
  #  :resolved -- user's participation is resolved with this page
  #  :all_resolved -- everyone's participation is resolved.
  #
  def updated(page, options={})
    raise PermissionDenied.new unless self.may?(:edit, page)
    now = Time.now

    # create self's participation if it does not exist
    my_part = find_or_build_participation(page)
    my_part.update_attributes(
      :changed_at => now, :viewed_at => now, :viewed => true,
      :resolved => (options[:resolved] || options[:all_resolved] || my_part.resolved?)
    )

    unless page.contributors.include?(self)
      page.contributors_count +=1
    end
     
    # update everyone's participation
    page.user_participations.each do |party|
      unless party.user_id == self.id
        party.resolved = options[:all_resolved] || party.resolved?
        party.viewed = false
        party.inbox = true if party.watch?
      end
      party.save      
    end
    # this is unfortunate, because perhaps we have already just modified the page?
    page.resolved = options[:all_resolved] || page.resolved?
    page.updated_at = now
    page.updated_by = self
  end

  ##
  ## PAGE SHARING
  ##

  # valid options:
  #  :access -- one of nil, :admin, :edit, :view (nil will remove access)
  #  :grant_access -- like :access, but is only used to improve access, not remove it.
  #  :message -- text message to send
  #  :send_emails -- true or false. send email to recipients?
  #
  # The needed user_participation and group_partication objects will get saved
  # unless page is modified, in which case they will not get saved.
  # (assuming that page.save will get called eventually, which will then save
  # the new participation objects)
  #
  def share_page_with!(page, recipients, options)
    return true unless recipients
    options[:notify] = true if options[:message] or options[:send_emails]

    users, groups, emails = Page.parse_recipients!(recipients)
    users_to_email = []
    send_emails    = options.delete(:send_emails)
    mailer_options = options.delete(:mailer_options)
    message        = options[:message]

    ## add users to page
    users.each do |user|
      if self.share_page_with_user!(page, user, options)
        users_to_email << user if user.wants_notification_email?
      end
    end

    ## add groups to page
    groups.each do |group|
      users_to_pester = self.share_page_with_group!(page, group, options)
      users_to_pester.each do |user|
        users_to_email << user if user.wants_notification_email?
      end
    end

    ## send access granted emails (TODO)
    # emails.each do |email|
    #   Mailer::page.deliver_share_notice_with_url_access(email, msg, mailer_options)
    # end

    ## send notification emails
    if send_emails and mailer_options
      users_to_email.each do |user|
        #logger.info '----------------- emailing %s' % user.email
        Mailer.deliver_share_notice(user, message, mailer_options)
      end
    end
  end

  # just like share_page_with, but don't do any actual sharing, just
  # raise an exception of there are any problems with sharing.
  def may_share_page_with!(page,recipients,options)
    return true unless recipients
    users, groups, emails = Page.parse_recipients!(recipients)
    users.each do |user|
      self.may_share!(page, user, options)
    end
    groups.each do |group|
      self.may_share!(page, group, options)
    end
  end

  # 
  # share a page with another user
  # 
  # see may_share!() for when a user may share a page.
  # also, we don't grant new permissions if the user already has the permissions
  # via a group membership.
  # 
  # see share_page_with!() for options
  #
  def share_page_with_user!(page, user, options={})
    may_share!(page,user,options)
    attrs = {}

    if options[:notify]
      attrs[:inbox] = true
    end
    if options[:message]
      attrs[:notice] = {:user_login => self.login, :message => options[:message], :time => Time.now}
    end

    if options.key?(:access) # might be nil
      attrs[:access] = options[:access]
    else
      options[:grant_access] ||= :view
      unless user.may?(options[:grant_access], page)
        attrs[:grant_access] = options[:grant_access] || :view
      end
    end

    upart = page.add(user, attrs)
    upart.save! unless page.changed?
  end

  def share_page_with_group!(page, group, options={})
    may_share!(page,group,options)
    if options.key?(:access) # might be nil
      gpart = page.add(group, :access => options[:access])
    else
      options[:grant_access] ||= :view
      gpart = page.add(group, :grant_access => options[:grant_access])
    end
    gpart.save! unless page.changed?

    # when we get here, the group should be able to view the page.

    attrs = {}
    users_to_pester = []
    if options[:notify]
      attrs[:inbox] = true
      users_to_pester = group.users.select do |user|
        self.may_pester?(user)
      end
      if options[:message]
        attrs[:notice] = {:user_login => self.login, :message => options[:message], :time => Time.now}
      end
      users_to_pester.each do |user|
        upart = page.add(user, attrs)
        upart.save! unless page.changed?
      end
    end

    users_to_pester # returns users to pester so they can get an email, maybe.
  end

  #
  # check that +self+ may pester user and has admin access if sharing requires
  # granting new access. 
  #
  def may_share!(page,entity,options)
    user  = entity if entity.is_a? User
    group = entity if entity.is_a? Group
    access = options[:access] || options[:grant_access] || :view
    if user
      if page.public? and !self.may_pester?(user)
        raise PermissionDenied.new('You are not allowed to share this page with %s'[:share_msg_pester_denied] %  user.login)
      elsif access.nil?
        if !user.may?(:view,page)
          raise PermissionDenied.new('%s is not allowed to view this page. They must be granted greater access first.'[:share_msg_grant_required] % user.login)
        end
      elsif !user.may?(access, page)
        if !self.may?(:admin,page)
          raise PermissionDenied.new('You are not allowed to change the access permissions of this page'[:share_msg_permission_denied])
        elsif !self.may_pester?(user)
          raise PermissionDenied.new('You are not allowed to share this page with %s'[:share_msg_pester_denied] % user.login)
        end
      end
    elsif group
      unless group.may?(access,page)
        unless self.may?(:admin,page) and self.may_pester?(group)
          raise PermissionDenied.new('Your not allowed to share this page with %s'[:share_msg_pester_denied] % group.name)
        end
      end
    end
  end


end
