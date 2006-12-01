class Tool < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :subcategory
  belongs_to( :created_by, 
              :class_name => 'User', 
              :foreign_key => 'created_by_id' )
  belongs_to( :updated_by,
              :class_name => 'User',
              :foreign_key => 'updated_by_id' )

  before_save :update_updated_by

  validates_presence_of :name

  def update_updated_by
    self.updated_by = User.current_user if User.current_user
  end
  
  def initialize(attributes = nil)
    super(attributes)

    if User.current_user && !created_by
      self.created_by = User.current_user
    end
  end
end
