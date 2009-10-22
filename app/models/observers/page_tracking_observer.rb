class PageTrackingObserver < ActiveRecord::Observer
  observe :page, :user_participation, :group_participation, :post, :wiki

  def after_create(model)
    if User.current
      if model.is_a? Page
        page = model
        PageHistory::PageCreated.create!(:user => User.current, :page => page)
      end
    end
  end

  def after_save(model)
    if User.current
      if model.is_a? UserParticipation
        up = model
        PageHistory::GrantUserFullAccess.create!(:user => User.current, :page => up.page, :object => up.user)   if up.granted_user_full_access?
        PageHistory::GrantUserWriteAccess.create!(:user => User.current, :page => up.page, :object => up.user)  if up.granted_user_write_access?
        PageHistory::GrantUserReadAccess.create!(:user => User.current, :page => up.page, :object => up.user)   if up.granted_user_read_access?
        PageHistory::StartWatching.create!(:user => User.current, :page => up.page)                             if up.start_watching?
        PageHistory::StopWatching.create!(:user => User.current, :page => up.page)                              if up.stop_watching?
        PageHistory::AddStar.create!(:user => User.current, :page => up.page)                                   if up.star_added?
        PageHistory::RemoveStar.create!(:user => User.current, :page => up.page)                                if up.star_removed?
      end

      if model.is_a? GroupParticipation
        gp = model
        PageHistory::GrantGroupFullAccess.create!(:user => User.current, :page => gp.page, :object => gp.group)  if gp.granted_group_full_access?
        PageHistory::GrantGroupWriteAccess.create!(:user => User.current, :page => gp.page, :object => gp.group) if gp.granted_group_write_access?
        PageHistory::GrantGroupReadAccess.create!(:user => User.current, :page => gp.page, :object => gp.group)  if gp.granted_group_read_access?
      end

      if model.is_a? Post and model.discussion.page
        post = model
        PageHistory::AddComment.create!(:user => User.current, :page => post.discussion.page, :object => post) if post.created_at == post.updated_at
      end
    end
  end  

  def after_update(model)
    if User.current
      if model.is_a? Page
        page = model
        PageHistory::ChangeTitle.create!(:user => User.current, :page => page)  if page.title_changed?
        PageHistory::Deleted.create!(:user => User.current, :page => page)      if page.deleted?
        PageHistory::MakePrivate.create!(:user => User.current, :page => page)  if page.marked_as_private?
        PageHistory::MakePublic.create!(:user => User.current, :page => page)   if page.marked_as_public?
      end

      if model.class == Wiki
        wiki = model
        PageHistory::UpdatedContent.create(:user => User.current, :page => Page.find(:first, :conditions => {:data_type => "Wiki", :data_id => wiki.id})) if wiki.body_changed?
      end

      if model.is_a? Post and model.discussion.page
        post = model
        PageHistory::UpdateComment.create!(:user => User.current, :page => post.discussion.page, :object => post) if post.body_changed?
      end
    end
  end

  def after_destroy(model)
    if User.current    
      if model.is_a? UserParticipation
        up = model
        PageHistory::RevokedUserAccess.create!(:user => User.current, :page => up.page, :object => up.user)
      end

      if model.is_a? GroupParticipation
        gp = model
        PageHistory::RevokedGroupAccess.create!(:user => User.current, :page => gp.page, :object => gp.group)
      end

      if model.is_a? Post and model.discussion.page
        post = model
        PageHistory::DestroyComment.create!(:user => User.current, :page => post.discussion.page, :object => post)
      end
    end
  end
end
