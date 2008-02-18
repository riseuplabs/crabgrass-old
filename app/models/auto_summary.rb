class AutoSummary < ActiveRecord::Base
  belongs_to :page
  
  # currently we only use a field called 'body'
  # we also talked about having a 'keywords' field
  #
  # elijah doesn't like calling this AutoSummary, and should feel free
  # to change the name to IndexedPage or IndexedData or SphinxDocument
  # or whatever else sounds better
end
