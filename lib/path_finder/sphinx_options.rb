module PathFinder::SphinxOptions

  def self.options_for_me(path, options)
    options
  end

  def self.options_for_public(path, options)
    options.merge({
      :public => true
    })
  end

  def self.options_for_user(path, options)
    user = options[:callback_arg_user]
    user_id = user.is_a?(User) ? user.id : user.to_i

    options.merge({
      :public => true,
      :secondary_user_ids => [user_id]
    })
  end

  def self.options_for_group(path, options)
    group = options[:callback_arg_group]
    group_id = group.is_a?(Group) ? group.id : group.to_i

    options.merge({
     :public => true,
     :secondary_group_ids => [group_id]
    })
  end
end
