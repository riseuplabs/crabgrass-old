class Task < ActiveRecord::Base

  belongs_to :task_list
#  has_and_belongs_to_many :users, :foreign_key => 'task_id'
  has_many :task_participations, :dependent => :destroy
  has_many :users, :through => :task_participations
  acts_as_list :scope => :task_list
  format_attribute :description
  validates_presence_of :name

  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

  before_create :set_user
  def set_user
    if User.current or self.created_by
      self.created_by ||= User.current
      self.updated_by = self.created_by
    end
    true
  end

  def owner_name
    task_list.page.owner_name if task_list.page
  end

  def completed=(is_completed)
    if is_completed
      self.completed_at = Time.now
    else
      self.completed_at = nil
    end
  end

  def completed
    completed_at != nil && completed_at < Time.now
  end
  alias :completed? :completed

  def past_due?
    !completed? && due_at && due_at.to_date < Date.today
  end
  alias :overdue? :past_due?

end
