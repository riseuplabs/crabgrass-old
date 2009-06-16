require 'greencloth'

class DropSummaryFromGroups < ActiveRecord::Migration
  def self.up
   
    # I have decided that using activerecord in migrations should be avoided. 
    # It causes more trouble than it is worth: when migrating a database, 
    # the model code that is used is based on the very newest database, and if
    # you try to use these models on the old database while it is getting migrated
    # then all sorts of things will likely break.
    # Yes, you could incrementally update the codebase, migrate, then update,
    # but this is a pita.

    connection = Profile.connection

    groups = connection.select_rows('SELECT groups.id, groups.name, groups.summary FROM groups')
    groups.each do |id, name, summary|
      next if summary.empty?
      summary_html = connection.quote(GreenCloth.new(summary, name, [:lite_mode]).to_html)
      summary = connection.quote(summary)
      public_profile_id = connection.select_value("
        SELECT id FROM `profiles`
        WHERE `profiles`.entity_id = #{id} AND `profiles`.entity_type = 'Group' AND (profiles.`stranger` = 1)
      ")
      if public_profile_id
        connection.execute("
          UPDATE `profiles`
          SET `updated_at` = NOW(), `summary` = #{summary}, `summary_html` = #{summary_html}
          WHERE `id` = #{public_profile_id}
        ")
      else
        connection.execute("
          INSERT INTO `profiles` (`stranger`, `entity_type`, `entity_id`, `updated_at`, `created_at`, `summary`, `summary_html`)
          VALUES(1, 'Group', #{id}, NOW(), NOW(), #{summary}, #{summary_html})
        ")
      end
    end
    remove_column :groups, :summary
  end

  def self.down
    #not reversible
    add_column :groups, :summary, :string
  end

end
