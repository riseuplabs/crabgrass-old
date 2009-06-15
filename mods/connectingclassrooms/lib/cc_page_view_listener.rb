class CcPageViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def author_info(context)
    profile=context[:post].user.profiles.first
    h "#{profile.organization} (#{profile.place})"
  end

end
