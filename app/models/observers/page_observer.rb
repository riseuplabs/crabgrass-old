class PageObserver < ActiveRecord::Observer
  def after_save(page)
  end

  def after_update(page)
    PageHistory::ChangeName.create!(:user => User.current, :page => page)   if page.title_changed?
    PageHistory::AddStar.create!(:user => User.current, :page => page)      if page.star_added?
    PageHistory::RemoveStar.create!(:user => User.current, :page => page)   if page.star_removed?
    PageHistory::Deleted.create!(:user => User.current, :page => page)      if page.deleted?
    PageHistory::MakePrivate.create!(:user => User.current, :page => page)  if page.marked_as_private?
    PageHistory::MakePublic.create!(:user => User.current, :page => page)   if page.marked_as_public?
  end  

  def after_destroy(page)
  end
end
