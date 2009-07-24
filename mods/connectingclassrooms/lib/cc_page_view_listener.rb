class CcPageViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def author_info(context)
    profile=context[:post].user.profile
    if profile.place
      h "#{profile.organization} (#{profile.place})"
    else
      h "#{profile.organization}"
    end
  end

end
