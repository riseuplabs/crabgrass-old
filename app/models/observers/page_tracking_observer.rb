class PageTrackingObserver < ActiveRecord::Observer
  observe :page, :user_participation 

  def after_save(model)
    if model.class == UserParticipation
      user_participation = model
      PageHistory::StartWatching.create!(:user => User.current, :page => user_participation.page) if user_participation.start_watching?
      PageHistory::StopWatching.create!(:user => User.current, :page => user_participation.page)  if user_participation.stop_watching?
      PageHistory::AddStar.create!(:user => User.current, :page => user_participation.page)       if user_participation.star_added?
      PageHistory::RemoveStar.create!(:user => User.current, :page => user_participation.page)    if user_participation.star_removed?
    end
  end  

  def after_update(model)
    if model.class == Page
      page = model
      PageHistory::ChangeName.create!(:user => User.current, :page => page)   if page.title_changed?
      PageHistory::Deleted.create!(:user => User.current, :page => page)      if page.deleted?
      PageHistory::MakePrivate.create!(:user => User.current, :page => page)  if page.marked_as_private?
      PageHistory::MakePublic.create!(:user => User.current, :page => page)   if page.marked_as_public?
    end
  end
end
