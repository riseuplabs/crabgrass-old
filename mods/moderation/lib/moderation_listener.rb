class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if may_moderate?
  end
end
