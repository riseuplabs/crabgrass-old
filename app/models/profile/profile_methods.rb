=begin

  a mix-in for Group and User associations with Profiles.
  TODO: filter on language too

=end

module ProfileMethods

  # returns the best profile for user to see
  def visible_by(user)
    if user
      relationships = proxy_owner.relationships_to(user)

      # site relationship settings are for user <=> user relationships only
      filter_relationships_for_site(relationships) unless proxy_owner.is_a? Group

      profile = find_by_access(*relationships)
    else
      profile = find_by_access :stranger
    end
    profile || Profile.new
  end

  # returns the first profile that matches one of the access symbols in *arg
  # in this order of precedence: foe, friend, peer, fof, stranger.
  def find_by_access(*args)
    return find_by_no_access if args.empty?

    args.map!{|i| if i==:member; :friend; else; i; end}

    conditions = args.collect{|access| "profiles.`#{access}` = ?"}.join(' OR ')
    find(
      :first,
      :conditions => [conditions] + ([true] * args.size),
      :order => 'foe DESC, friend DESC, peer DESC, fof DESC, stranger DESC'
    )
  end

  def find_by_no_access
    fields = [:foe, :friend, :peer, :fof, :stranger]
    conditions = fields.collect{|access| "profiles.`#{access}` = ?"}.join(' AND ')
    find(
      :first,
      :conditions => [conditions] + ([false] * fields.size),
      :order => 'foe DESC, friend DESC, peer DESC, fof DESC, stranger DESC'
    )
  end

  # a shortcut to grab the 'public' profile
  def public
    @public_profile ||= (find_by_access(:stranger) || create_or_build(:stranger => true))
  end

  # a shortcut to grab the 'private' profile
  def private
    @private_profile ||= (find_by_access(:friend) || create_or_build(:friend => true))
  end

  def hidden
    @hidden_profile ||= (find_by_access || create_or_build)
  end

  def create_or_build(args={})
    if proxy_owner.new_record?
      build(args)
    else
      create(args)
    end
  end

  protected

  def filter_relationships_for_site(relationships)
    # filter possible profiles on current_site
    if site = Site.current
      relationships.delete(:stranger) unless site.profile_enabled? 'public'
      relationships.delete(:friend) unless site.profile_enabled? 'private'
    end
  end
end

