module CacheHelper

  def group_cache_key(group, options={})
    may_admin = current_user.may?(:admin, group)
    params.merge(:version => group.version, :updated_at => group.updated_at.to_i,
        :lang => session[:language_code], :path => nil, :may_admin => may_admin,
        :authenticity_token => nil, :access => @access).merge(options)
  end

  def me_cache_key
    params.merge(:user_id => current_user.id, :version => current_user.version, :path => nil, :authenticity_token => nil)
  end

  def menu_cache_key
    {:user_id => current_user.id, :version => current_user.version}
  end

end
