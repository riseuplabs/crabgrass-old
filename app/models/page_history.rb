class PageHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :page
  belongs_to :object, :polymorphic => true

  validates_presence_of :user, :page
end

class PageHistory::ChangeTitle    < PageHistory; end
class PageHistory::AddStar        < PageHistory; end
class PageHistory::RemoveStar     < PageHistory; end
class PageHistory::MakePublic     < PageHistory; end
class PageHistory::MakePrivate    < PageHistory; end
class PageHistory::Deleted        < PageHistory; end
class PageHistory::StartWatching  < PageHistory; end
class PageHistory::StopWatching   < PageHistory; end
class PageHistory::UpdatedContent < PageHistory; end

class PageHistory::GrantGroupFullAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantGroupWriteAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantGroupReadAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::RevokedGroupAccess < PageHistory
  validates_format_of :object_type, :with => /Group/
  validates_presence_of :object_id
end

class PageHistory::GrantUserFullAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::GrantUserWriteAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::GrantUserReadAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::RevokedUserAccess < PageHistory
  validates_format_of :object_type, :with => /User/
  validates_presence_of :object_id
end

class PageHistory::AddComment < PageHistory
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end

class PageHistory::UpdateComment < PageHistory
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end

class PageHistory::DestroyComment < PageHistory
  validates_format_of :object_type, :with => /Post/
  validates_presence_of :object_id
end
