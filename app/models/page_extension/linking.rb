=begin

THIS CODE IS DISABLED FOR NOW, BECAUSE WE DON'T YET HAVE A NEED FOR POLYMORPHIC
PAGE LINKING, OR NON-POLYMORPHIC FOR THAT MATTER.

here is the migration for polymorphic links:

class CreatePolyLinks < ActiveRecord::Migration
  def self.up
    # even though this is a join table, we need a primary id
    # because that is what acts_as_list wants
    create_table "links", :force => true do |t|
      t.references :parent
      t.references :child, :polymorphic => true
      t.integer :position, :default => 0
    end

    # note: the name suffixes with digits are specifying the key length to schema.rb
    execute "CREATE INDEX pc_0_0_2 ON links (parent_id, child_id, child_type(2))"
    execute "CREATE INDEX cp_0_2_0 ON links (child_id, child_type(2), parent_id)"
  end

  def self.down
    drop_table :links
  end
end

here is the migration for non poly links:

class CreatePolyLinks < ActiveRecord::Migration
  def self.up
    # even though this is a join table, we need a primary id
    # because that is what acts_as_list wants
    create_table "links", :force => true do |t|
      t.references :parent
      t.references :child
      t.integer :position, :default => 0
    end

    add_index :links, [:parent_id, :child_id], :name => :pc
    add_index :links, [:child_id, :parent_id], :name => :cp
  end

  def self.down
    drop_table :links
  end
end

=end





#
# PageExtension::Linking -- All things related to pages linking to other pages.
#
#
# ASSOCIATIONS
#
# Imagine a tree of Page objects, where each page can have any number of
# parents and and number of children. OK, it is really a graph, but you get
# the idea.
#
# On the parent side, the child nodes are available through 'children'
# and the edges for the nodes are called 'links'
#
# The children of each page can be either pages or assets. To access just the
# children that are assets, use the association 'child_assets'. For just pages,
# use 'child_pages'.
#
# Here are the associations on the parent Page:
#
# class Page
#   has_many :links, {:foreign_key=>"parent_id", :dependent=>:destroy, :class_name=>"Link"}
#   has_many :child_assets, {:source_type=>"Asset", :through=>:links, :class_name=>"Asset", :source=>:child}
#   has_many :child_pages, {:source_type=>"Page", :through=>:links, :class_name=>"Page", :source=>:child}
# end
#
# On the child side, Asset and Page differ. For assets, the links to the parent
# are available in an association called 'links'. The parents themselves are
# called 'parents_of_children'
#
# Here are the associations on the child Asset:
#
# class Asset
#   has_many :links, {:as=>:child, :dependent=>:destroy, :class_name=>"Link"}
#   has_many :parents_of_children, { :foreign_key => "parent_id", :through => :links, :source => :parent, :class_name => "Collection" }
# end
#
# When a page is a child, the associations are slightly different. Since
# 'links' is already used for the parent -> link -> child association, the
# association on the child side is called 'links_as_child'
#
# Here are the associations on the child Page:
#
# class Page
#   has_many :links_as_child, {:as=>:child, :dependent=>:destroy, :class_name=>"Link"}
#   has_many :parents_of_children, { :foreign_key => "parent_id", :through => :links, :source => :parent, :class_name => "Collection" }
# end
#
# All these associations are created automatically by has_many_polymorph.
# Very cool, except that it can be confusing to figure out what is going on
# because all the associations are automatic.
#
#
# ADDING AND REMOVING LINKS
#
# In order to add or remove a link between pages, you should ONLY use these
# methods: add_child(), add_child!(), remove_child!()
#
#
# OTHER METHODS
#
# parent.child_ids
#

module PageExtension::Linking

  def self.included(base)
    base.instance_eval do

      has_many_polymorphs :children, :as => :parent, :through => :links,
       :order => 'position', :from => [:pages, :assets],
       :rename_individual_collections => true, :dependent => :destroy

      alias_method :parents, :parents_of_children
    end
  end

  def add_child!(child, position = nil)
    Link.create! :parent => self, :child => child, :position => position
    reset_links(child)
    true
  end

  # like add_child!, but does not save the page. Used to build
  # the links in memory when creating a page.
  def add_child(child, position = nil)
    if child.respond_to?(:links_as_child)
      child.links_as_child.build(:parent => self, :position => position)
    else
      child.links.build(:parent => self, :position => position)
    end
  end

  def remove_child!(child)
    link = self.links.detect{|link| link.child_id == child.id}
    reset_links(child)
    link.destroy
  end

  # If you pass a collection_id to a Page the Page will be added to the Collection.
  def collection_id=(id)
    if collection = Collection.find_by_id(id)
      collection.add_child self
    end
  end

  private

  def reset_links(child)
    if child.respond_to?(:links_as_child)
      child.links_as_child.reset
    else
      child.links.reset
    end
    child.parents_of_children.reset
    self.links.reset
    self.children.reset
  end

end


=begin

  I am not sure that I am happy with polymorphic links

  Here is the non-polymorphic code:

  class Page
    has_many :up_links, :as => :child, :class_name => 'Link', :dependent => :destroy
    has_many :collections, :through => :up_links, :source => :parent, :order => 'links.position'
  end

  class Collection
    has_many :down_links, :foreign_key => 'parent_id', :class_name => 'Link',
      :order => 'position', :dependent => :destroy
    has_many :pages, :through => :down_links, :source => :child, :order => 'links.position'
  end

=end


