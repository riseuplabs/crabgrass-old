class MenuItem < ActiveRecord::Base

  belongs_to :group
  acts_as_list :scope => :group

  TYPES={
    'external link'[:external_link_menu_item]=>:external,
    'local link'[:local_link_menu_item]=>:local,
    'page'[:page_menu_item]=>:page,
    'tag'[:tag_menu_item]=>:tag,
    'search'[:search_menu_item]=>:search
  }

end
