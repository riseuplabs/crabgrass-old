# renaming the plugin inside a plugin migration is a more complex
# than doing it in the app migration
# .
# you must run this migration before script/generate plugin_migration
class RenameGibberizeModToTranslator < ActiveRecord::Migration
  def self.up
    begin
      ActiveRecord::Base.connection.execute "UPDATE plugin_schema_info SET plugin_name='translator' WHERE plugin_name='gibberize'"
    rescue ActiveRecord::StatementInvalid => exc
      # plugin_schema_info table does not exist. this means we're good -- nothing to rename.
    end
  end

  def self.down
    begin
      ActiveRecord::Base.connection.execute "UPDATE plugin_schema_info SET plugin_name='gibberize' WHERE plugin_name='translator'"
    rescue ActiveRecord::StatementInvalid => exc
      # plugin_schema_info table does not exist. this means we're good -- nothing to rename.
    end
  end
end
