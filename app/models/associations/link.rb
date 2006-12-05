# a link holds the data representing a connection from one page to another.
# links are uni-directional. however, creating a link in one direction also
# triggers the creation of another link object in the other direction.
# so, in practice, every link is bi-directional.

class Link < ActiveRecord::Base
  belongs_to :page
  belongs_to :other_page, :class_name => 'Page'
end
