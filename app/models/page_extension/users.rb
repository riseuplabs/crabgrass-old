=begin

  PAGE RELATIONSHIP TO USERS

=end

module PageExtension::Users

  # when we save, we want the users association to relect whatever changes have
  # been made to user_participations
  def reset_users
    self.users.reset
    true
  end

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

  # like users.with_access, but uses already included data
  def users_with_access
    user_participations.collect{|part| part.user if part.access }.compact
  end

  # A contributor has actually modified the page in some way. A participant
  # simply has a user_participation record, maybe they have never even seen
  # the page.
  # This method is like users.contributed, but uses already included data
  def contributors
    user_participations.collect{|part| part.user if part.changed_at }.compact
  end

  # like user_participations.find_by_user_id, but uses already included data
  def participation_for_user(user)
    if user.real?
      user_participations.detect{|p| p.user_id==user.id }
    else
      false
    end
  end

  # A list of the user participations, with the following properties:
  # * sorted first by access level, second by changed_at, third by login.
  # * limited to users who have access OR changed_at
  # This uses a limited query, otherwise it takes forever on pages with many participants.
  def sorted_user_participations(options={})
    options.reverse_merge!(
      :order=>'access ASC, changed_at DESC, users.login ASC',
      :limit => (options[:page] ? nil : 31),
      :include => :user,
      :conditions => 'access IS NOT NULL OR changed_at IS NOT NULL'
    )
    if options[:page]
      self.user_participations.paginate(:all, options);
    else
      self.user_participations.find(:all, options);
    end
  end

  # used for sphinx index
  def user_ids
    user_participations.collect{|upart|upart.user_id}
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

end # module

