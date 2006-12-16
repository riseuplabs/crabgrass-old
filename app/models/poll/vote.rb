class Polls::Vote < ActiveRecord::Base

  belongs_to :possible
  belongs_to :user
  # has_many :polls, :finder_sql => ''
end
