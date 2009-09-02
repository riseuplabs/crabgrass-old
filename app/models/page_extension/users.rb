=begin

  PAGE RELATIONSHIP TO USERS

=end

module PageExtension::Users

  def self.included(base)
    base.instance_eval do

      before_create :set_user

      belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
      belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
      has_many :user_participations, :dependent => :destroy
      has_many :users, :through => :user_participations do
        def with_access
          find(:all, :conditions => 'access IS NOT NULL')
        end
        def contributed
          find(:all, :conditions => 'changed_at IS NOT NULL')
        end
      end

      remove_method :user_ids
      after_save :reset_users
    end
  end

  ##
  ## CALLBACKS
  ##

  protected

  # when we save, we want the users association to relect whatever changes have
  # been made to user_participations
  def reset_users
    self.users.reset
    true
  end

  def set_user
    if User.current or self.created_by
      self.created_by ||= User.current
      self.created_by_login = self.created_by.login
      self.updated_by       = self.created_by
      self.updated_by_login = self.created_by.login
    end
    true
  end

  ##
  ## USERS
  ##

  public

  # used for sphinx index
  # e: why not just use the normal user_ids()? i guess the assumption is that
  # user_participations will always be already loaded if we are saving the page.
  def user_ids
    user_participations.collect{|upart|upart.user_id}
  end

  # like users.with_access, but uses already included data
  #def users_with_access
  #  user_participations.collect{|part| part.user if part.access }.compact
  #end

  # A contributor has actually modified the page in some way. A participant
  # simply has a user_participation record, maybe they have never even seen
  # the page.
  # This method is like users.contributed, but uses already included data
  #def contributors
  #  user_participations.collect{|part| part.user if part.changed_at }.compact
  #end

  ##
  ## USER PARTICIPATION
  ##

  # returns true if +user+ has contributed to the page
  def contributor?(user)
    participation_for_user(user).try(:changed_at)
  end

  # Returns the user participation object for +user+.
  # This method is almost always called on the current user.
  def participation_for_user(user)
    return false unless user.real?
    # grab the user_participation object and cache it in @uparts
    (@uparts ||= {})[user.id] ||= begin
      if @user_participations
        # if we currently have in-memory data for user_participations, we must use it.
        # why? participation_for_user is called sometimes on pages that have not yet been
        # saved. Also, heck, it is faster. There is a danger here, in that Rails is not
        # gauranteed to set the member variable @user_participations. If this is no longer
        # the case, a bunch of tests will fail.
        @user_participations.detect{|p| p.user_id==user.id }
      else
        # go ahead and fetch the one record we care about. We probably don't care about others
        # anyway.
        user_participations.find_by_user_id(user.id)
      end
    end
  end

  # A list of the user participations, with the following properties:
  # * sorted first by access level, second by changed_at, third by login.
  # * limited to users who have access OR changed_at
  # This uses a limited query, otherwise it takes forever on pages with many participants.
  def sorted_user_participations(options={})
    options[:page] ||= 1 if options.key?(:page)   # options[:page] might be set to nil
    options.reverse_merge!(
      :order=>'access ASC, changed_at DESC, users.login ASC',
      :limit => (options[:page] ? nil : 31),
      :include => :user,
      :conditions => 'access IS NOT NULL OR changed_at IS NOT NULL'
    )
    if options[:page]
      self.user_participations.paginate(options);
    else
      self.user_participations.find(:all, options);
    end
  end

end # module

