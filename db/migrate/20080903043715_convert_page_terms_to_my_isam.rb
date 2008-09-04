#
# in order to build a fulltext index of access_ids, the table must be MyISAM 
#

class ConvertPageTermsToMyIsam < ActiveRecord::Migration
  def self.up
    connection = ActiveRecord::Base.connection
    connection.execute 'ALTER TABLE page_terms ENGINE = MyISAM'
    connection.execute 'CREATE FULLTEXT INDEX idx_fulltext ON page_terms(access_ids, tags)'
    add_index :page_terms, :page_id, :name => :page_id
  end

  def self.down
    # it is unsupported operation to convert a MyISAM table to a InnoDB table.
    remove_index :page_terms, :name => :page_id
    remove_index :page_terms, :name => :idx_fulltext
  end
end

