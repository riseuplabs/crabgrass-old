class PageHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :page

  validates_presence_of :user, :page
end

class PageHistory::ChangeName     < PageHistory; end
class PageHistory::AddStar        < PageHistory; end
class PageHistory::RemoveStar     < PageHistory; end
class PageHistory::MakePublic     < PageHistory; end
class PageHistory::MakePrivate    < PageHistory; end
class PageHistory::Deleted        < PageHistory; end
class PageHistory::StartWatching  < PageHistory; end
class PageHistory::StopWatching   < PageHistory; end
