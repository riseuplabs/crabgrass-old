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
        :after_add => :update_tag_cache, :after_remove => :update_tag_cache
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
  ## PERMISSIONS
  ##

  # this method gets called a lot
  # ex) current_user.may?(:admin,@page)
  def may?(perm, page)
    begin
      may!(perm,page)
    rescue PermissionDenied
      false
    end
  end
  
  def may!(perm,page)
    ((@access||={})[page.id] ||= {})[perm] ||= calculate_access!(perm,page)
  end

  # basic permissions:
  #   :view or :read -- user can see the page.
  #   :edit or :change -- user can participate.
  #   :admin -- user can destroy the page, change access.
  # conditional permissions:
  #   :comment -- sometimes viewers can comment and sometimes only participates can.
  #   (NOT SUPPORTED YET)
  #
  # :view should only return true if the user has access to view the page
  # because of participation objects, NOT because the page is public.
  #
  def calculate_access!(perm, page)
    perm = :edit if perm == :comment
    upart = page.participation_for_user(self)
    gparts = page.participation_for_groups(all_group_ids)
    if upart or gparts.any?
      parts = []
      parts += gparts if gparts.any?
      parts += [upart] if upart
      part_with_best_access = parts.min {|a,b|
        (a.access||100) <=> (b.access||100)
      }
      # allow :view if the participation exists at all
      return ( part_with_best_access.access || ACCESS[:view] ) <= ACCESS[perm]
    end
    raise PermissionDenied.new
  end

  # zeros out the in-memory page access cache
  # generally, this is called for you, but must be called manually 
  # in the case where page access was via a group and that group loses
  # page access.
  def clear_access_cache
    @access = nil
  end

  ##
  ## USER PARTICIPATIONS
  ##

  # makes self a participant of a page. 
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
      self.create_participation(page, part_attrs)
    end  
    page.updated_by_id_will_change!
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
    participation.update_attributes(part_attrs)
  end
  ## called only by update_participation
  def repeat_notice?(current_notices, new_notice)
    new_notice = new_notice.first
    current_notices.detect do |notice|
      notice[:message] == new_notice[:message] and notice[:user_login] == new_notice[:user_login]
    end
  end
  ## called only by add_page
  def create_participation(page, part_attrs)
    # user_participations.build doesn't update the pages.users
    # until it is saved, so we use create instead
    page.user_participations.create(part_attrs.merge(
      :page_id => page.id, :user_id => id,
      :resolved => page.resolved?))
  end

  # remove self from the page.
  # only call by page.remove(user)    
  def remove_page(page)
    clear_access_cache
    page.users.delete(self)
    page.updated_by_id_will_change!
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
    # create self's participation if it does not exist
    find_or_build_participation(page)

    unless page.contributors.include?(self)
      page.contributors_count +=1
    end
     
    # update everyone's participation
    now = Time.now
    page.user_participations.each do |party|
      if party.user_id == self.id
        party.changed_at = now
        party.viewed_at = now
        party.viewed = true
        party.resolved = options[:resolved] || options[:all_resolved] || party.resolved?
      else
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
  #  :access -- one of nil, :admin, :edit, :view
  #  :message -- text message to send
  #  :send_emails -- true or false. send email to recipients?
  #
  def share_page_with!(page, recipients, options)
    return true unless recipients
    users, groups, emails = parse_recipients!(recipients)
    users_to_email = []

    ## add users to page
    users.each do |user|
      if self.share_page_with_user!(page, user, options)
        users_to_email << user if user.wants_notification_email?
      end
    end

    ## add groups to page
    groups.each do |group|
      users_succeeded = self.share_page_with_group!(page, group, options)
      users_succeeded.each do |user|
        users_to_email << user if user.wants_notification_email?
      end
    end

    ## send access granted emails (TODO)
    # emails.each do |email|
    #   Mailer.deliver_page_notice_with_url_access(email, msg, mailer_options)
    # end

    ## send notification emails
    if options[:send_emails]
      users_to_email.each do |user|
        #logger.info '----------------- emailing %s' % user.email
        Mailer.deliver_page_notice(user, msg, mailer_options)
      end
    end

    page.save
  end

  # just like share_page_with, but don't do any actual sharing, just
  # raise an exception of there are any problems with sharing.
  def may_share_page_with!(page,recipients,options)
    return true unless recipients
    users, groups, emails = parse_recipients!(recipients)
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
  # options may include:
  # * +:message => 'text to send to user'+ (default is empty)
  # * +:access => 'admin'+ (or one of 'admin', 'edit', 'view', nil. default is nil)
  #   nil means do not grant additional access more than the user already has
  #
  def share_page_with_user!(page, user, options={})
    may_share!(page,user,options)
    attrs = {}

    if options[:message]
      attrs[:notice] = {:user_login => self.login,
        :message => options[:message], :time => Time.now}
    end
    if options[:access] and !user.may?(options[:access],page)
      attrs[:access] = options[:access]
    end

    page.add(user, attrs)
  end

  def share_page_with_group!(page, group, options={})
    options[:access] ||= :view
    may_share!(page,group,options)
    page.add group, options

    # when we get here, the group should be able to view the page.
    users_to_pester = group.users.select do |user|
      self.may_pester?(user)
    end
    if options[:message]
      attrs = {:notice => {:user_login => self.login,
        :message => options[:message], :time => Time.now}}
      users_to_pester.each do |user|
        page.add user, attrs
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
    if user
      if page.public? and !self.may_pester?(user)
        raise PermissionDenied.new('You are not allowed to share this page with %s'[:share_msg_pester_denied] %  user.login)
      elsif options[:access].nil?
        if !user.may?(:view,page)
          raise PermissionDenied.new('%s is not allowed to view this page. They must be granted greater access first.'[:share_msg_grant_required] % user.login)
        end
      elsif !user.may?(options[:access], page)
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

  # parses a list of recipients, turning them into email, user, or group
  # objects as appropriate.
  def parse_recipients!(recipients)
    users = []; groups = []; emails = []; errors = []
    if recipients.is_a? Hash
      to = []
      recipients.each do |key,value|
        to << key if value == '1'
      end
    elsif recipients.is_a? Array
      to = recipients
    elsif recipients.is_a? String
      to = recipients.split(/[\s,]/)
    end
    to.each do |entity|
      if entity.is_a? Group
        groups << entity
      elsif entity.is_a? User
        users << entity
      elsif entity =~ RFC822::EmailAddress
        emails << entity
      elsif g = Group.get_by_name(entity)
        groups << g
      elsif u = User.find_by_login(entity)
        users << u
      elsif entity.any?
        errors << '"%s" does not match the name of any users or groups and is not a valid email address'[:name_or_email_not_found] % entity.name
      end
    end

    unless errors.empty?
      raise ErrorMessages.new('Could not understand some recipients.', errors)
    end

    [users, groups, emails]
  end


end
