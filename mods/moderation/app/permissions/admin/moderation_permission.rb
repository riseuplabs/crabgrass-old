module Admin::ModerationPermission
  def may_moderate?
    current_user.moderator?
  end

  %w(index show new edit create update destroy).each do |action|
    %w(pages posts).each do |controller|
      alias_method "may_#{action}_#{controller}?".intern, :may_moderate?
    end
  end

end
