
# WikiLocks objects are protected by optimistic locking
# this means that if two users
class WikiLock < ActiveRecord::Base
  belongs_to :wiki

  validates_presence_of :wiki

  LOCKING_PERIOD = 120.minutes


  #   locks => {:document => {:by => user_id, :expires_at => Time},
  #                       'section-name' => {:by => user_id, :expires_at => Time}, ...}
  #
  # accessor for +locks+ attribute. The default value is +{}+
  serialize :locks, Hash
  serialize_default :locks, Hash.new

  def after_find
    update_expired_locks!
  end

  def all_sections
    wiki.all_sections
  end

  def lock!(section, user)
    locks[section] = {:by => user.id, :expires_at => Time.now.utc + LOCKING_PERIOD}
    update_attributes!({:locks => locks})
  end

  def unlock!(section, user, opts = {})
    if section == :document
      # wipe away everything. safer in case of stray locks
      locks.clear
    else
      locks.delete(section)
    end

    update_attributes!({:locks => locks})
  end

  def sections_open_for(user)
    open_to_everyone = all_sections - locks.keys
    open_to_user = open_to_everyone

    # take the sections open to everyone and add ones locked by this user
    # which must be open to that user
    locks.inject(open_to_user) do |matching, (section, lock)| # parens will splat a single [:document, {...}] input
      matching << section if lock[:by] == user.id
    end

    open_to_user.uniq
  end

  def sections_locked_for(user)
    all_sections - sections_open_for(user)
  end


  protected
  # this should be called every time WikiLocks is loaded from db
  # so that we may never see any expired locks
  def update_expired_locks!
    current_time = Time.now.utc

    updated_locks = locks.reject do |section, lock|
      # reject if past due and time is used
      lock[:expires_at] and lock[:expires_at] < current_time
    end

    # save locks if something changed
    if updated_locks != locks
      update_attributes!({:locks => updated_locks})
      self.reload
    end
  end

  # def [](key)
  #   locks[key]
  # end
  #
  # def []=(key, val)
  #   locks[key] = val
  # end
end
