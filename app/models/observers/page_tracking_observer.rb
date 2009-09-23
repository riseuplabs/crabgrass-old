class PageTrackingObserver < ActiveRecord::Observer
  observe :page, :user_participation, :post

  def after_save(model)
    if model.is_a? UserParticipation
      up = model
      PageHistory::StartWatching.create!(:user => User.current, :page => up.page)                             if up.start_watching?
      PageHistory::StopWatching.create!(:user => User.current, :page => up.page)                              if up.stop_watching?
      PageHistory::AddStar.create!(:user => User.current, :page => up.page)                                   if up.star_added?
      PageHistory::RemoveStar.create!(:user => User.current, :page => up.page)                                if up.star_removed?
      PageHistory::GrantUserFullAccess.create!(:user => User.current, :page => up.page, :object => up.user)   if up.granted_user_full_access?
    end

    if model.is_a? Post and model.discussion.page
      post = model
      PageHistory::AddComment.create!(:user => User.current, :page => post.discussion.page, :object => post) if post.created_at == post.updated_at
    end
  end  

  def after_update(model)
    if model.is_a? Page
      page = model
      PageHistory::ChangeTitle.create!(:user => User.current, :page => page)  if page.title_changed?
      PageHistory::Deleted.create!(:user => User.current, :page => page)      if page.deleted?
      PageHistory::MakePrivate.create!(:user => User.current, :page => page)  if page.marked_as_private?
      PageHistory::MakePublic.create!(:user => User.current, :page => page)   if page.marked_as_public?
    end

    if model.is_a? Post and model.discussion.page
      post = model
      PageHistory::UpdateComment.create!(:user => User.current, :page => post.discussion.page, :object => post) if post.body_changed?
    end
  end

  def after_destroy(model)
    if model.is_a? Post and model.discussion.page
      post = model
      PageHistory::DestroyComment.create!(:user => User.current, :page => post.discussion.page, :object => post)
    end
  end
end
