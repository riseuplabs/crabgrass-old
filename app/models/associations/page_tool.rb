# 
# join table for pages to have many polymorphic tools
# currently unused!

class PageTool < ActiveRecord::Base
  belongs_to :page
  belongs_to :tool, :polymorphic => true
end
