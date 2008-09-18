# a link holds the data representing a connection from one page to another.

class Link < ActiveRecord::Base
  belongs_to :colection, :foreign_key => 'from'
  belongs_to :page, :foreign_key => 'to'
end
