module Admin::ModerationPermission
  def may_moderate?
    current_user.moderator?
  end

  %w(index show new edit create update destroy).each do |action|
    alias_method "may_#{action}_pages?".intern,           :may_moderate?
  end
  
  %w(index update approve trash undelete).each do |action|
    %w(wall_posts discussion_posts).each do |controller|
      alias_method "may_#{action}_#{controller}?".intern, :may_moderate?
    end
  end

end
