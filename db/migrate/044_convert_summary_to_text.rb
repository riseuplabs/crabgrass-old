class ConvertSummaryToText < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `pages` MODIFY `summary` TEXT"
  end

  def self.down
    execute "ALTER TABLE `pages` MODIFY `summary` VARCHAR(255) default NULL"
  end
end

