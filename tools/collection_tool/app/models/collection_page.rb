class CollectionPage < ActiveRecord::Base
  belongs_to :collection
  belongs_to :page
end
