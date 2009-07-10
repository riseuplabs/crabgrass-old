#!/usr/bin/env ruby
unless $0 =~ /runner/
  runner = File.dirname(File.dirname(__FILE__)) + '/script/runner'
  exec("#{runner} #{__FILE__}")
end

#
# A script to merge two crabgrass databases. 
#

=begin

as root:
  sync-stopx.rb

as cg:
  rake db:migrate RAILS_ENV=production
  create stopx environment (database.yml, crabgrass.stopx.yml, environments/stopx.rb)
  rake db:migrate RAILS_ENV=stopx
  script/runner lib/bin/merge_databases.rb
  rake cg:update_page_terms RAILS_ENV=production

=end

require 'ruby-debug'

##
## stuff to configure
##

$database_from = {
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "crabgrass",
  :password => "ien1Zei2",
  :database => "stopx"
}

$database_to = :production    # whatever is configured in database.yml

$site_id = 7
$from_asset_dir = '/usr/apps/crabgrass/stopx/assets'

##
## Settings for crabgrass schema
## 

$model_merge_order = %w(PollVote User Discussion Post Wiki::Version Wiki Poll Page)

$exclude_models = %w(MigrationsInfo SchemaMigration PluginSchemaInfo Language Key Translation Tracking PageTerms Site Asset::Version PageTool TasksUser Event Activity Request Channel ChannelsUser Code Token StatusPost)

$table_to_model = {
  'asset_versions' => 'Asset::Version',
  'channels' => 'ChatChannel',
  'messages' => 'ChatMessage',
  'channels_users' => 'ChatChannelsUser',
  'crypt_keys' => 'ProfileCryptKey',
  'email_addresses' => 'ProfileEmailAddress',
  'im_addresses' => 'ProfileImAddress',
  'locations' => 'ProfileLocation',
  'notes' => 'ProfileNote',
  'phone_numbers' => 'ProfilePhoneNumber',
  'websites' => 'ProfileWebsite',
  'possibles' => 'PollPossible',
  'votes' => 'PollVote', 
  'wiki_versions' => 'Wiki::Version'
}

# these are models where we should ignore the foreign key id if a record
# with the same name (or login in the case of User) already exists. In these
# cases, we use the existing record.
$remap_models = {'User' => 'login', 'Group' => 'name', 'Tag' => 'name'}

class Page
  def fix_merge_error(attribute, message)
    if attribute == 'name'
      self.name = nil
    end
  end
end

class User
  attr_accessor :skip
  def fix_merge_error(attribute, message)
    if attribute == 'email'
      $email_count ||= 0
      self.email = 'error%s@localhost' % ($email_count+=1)
    elsif attribute == 'login'
      if self.login == 'test'
        self.skip = true
      end
    end
  end
end

class Post
  attr_accessor :skip
  def fix_merge_error(attribute, message)
    if attribute == 'user'
      # the user probably doesn't exist anymore, so we are not needed.
      self.skip = true
    end
  end
end

##
## HELPER METHODS
##

# get the list of models (excluding models that are STI subclasses)
def get_models
  models = []
  ActiveRecord::Migration.tables.each do |table_name|
    model_name = $table_to_model[table_name] || table_name.classify
    next if $exclude_models.include?(model_name)
    models << model_name.constantize
  end
  return models
end

def get_max_ids(models)
  hsh = {}
  models.each do |model|  
    if model.column_names.include?('id')
      hsh[model.class_name] = [ (model.maximum(:id)||0) + 1, hsh[model.class_name]||0 ].max
    end
  end
  return hsh
end

def sort_models(models)
  models.sort {|a,b|
    ($model_merge_order.index(a.name)||1000) <=> ($model_merge_order.index(b.name)||1000)
  }
end

#
# takes a record, and converts a particular foreign key to be compatible with the
# new database.
#
def new_foreign_key(record, foreign_type, foreign_key)
  id = record[foreign_key]       # ie record["user_id"]
  newid = nil
  if !id.nil?
    # try to remap the id to an existing record if we can
    if $remap_ids[foreign_type]
      newid = $remap_ids[foreign_type][id]
    end
    # if that fails, bump the id number
    if newid.nil? and $max_ids[foreign_type]
      newid = id + $max_ids[foreign_type]
    end
    # give up, and use the original id
    if newid.nil?
      newid = id
    end
  end
  return newid
end

# returns an array of [foreign_key_type, foreign_key_column] for all the foreign
# associations for the record. The reason this has to be done on the record and
# not the model is that only the record knows what the type is for polymorphic
# associations
def foreign_keys(record, associations)
  associations.collect do |association|
    foreign_key = association.primary_key_name
    foreign_type = if association.options[:foreign_type]
      record.send(association.options[:foreign_type])
    else
      association.klass.class_name
    end
    #p [foreign_type, foreign_key, $max_ids[foreign_type]]
    [foreign_type, foreign_key]
  end
end

def asset_path(asset_id)
  [$from_asset_dir, ("%08d" % asset_id).scan(/..../)].flatten.join('/')
end

##
## CODE THAT DOES THE MERGE
##

## GATHER INFO ON 'FROM' DB

ActiveRecord::Base.establish_connection $database_from

Page.delete_all('type = "StaticPage"')
Page.delete_all('type = "EventPage"')

models = get_models
models = sort_models(models)

remap_records = {}
$remap_models.each do |model_name, key_name|
  remap_records[model_name] = model_name.constantize.find(:all)
end

## GATHER INFO ON 'TO' DB

ActiveRecord::Base.establish_connection $database_to

$max_ids = get_max_ids(models)

$remap_ids = {} # eg {'User' => {from_id => to_id}}
$remap_models.each do |model_name, key_name|
  remap_records[model_name].each do |record_from|
    if record_to = model_name.constantize.find(:first, :conditions => {key_name => record_from[key_name]}) 
      $remap_ids[model_name] ||= {}
      $remap_ids[model_name][record_from.id] = record_to.id 
    end
  end
end

ActiveRecord::Base.record_timestamps = false
ThinkingSphinx.updates_enabled = false

models.each do |model|
  model.delete_observers

  puts "\n\n:::::::::::::: #{model.name} :::::::::::::::\n"
  model.class_eval do |base|
    base.write_inheritable_attribute("attr_protected", nil)
    base.write_inheritable_attribute("attr_accessible", nil)
  end

  ## EXPORT THE DATA

  ActiveRecord::Base.establish_connection $database_from
  Site.current = nil
  records = model.find(:all)
  puts '%s records' % records.size

  ## IMPORT THE DATA

  ActiveRecord::Base.establish_connection $database_to
  Site.current = Site.find($site_id)

  associations = model.reflect_on_all_associations.select do |association|
    association.macro == :belongs_to
  end

  records.each do |record|
    if $remap_ids[model.name] and $remap_ids[model.name][record.id]
      puts 'skipping %s: %s %s' % [model.name, record.id, record[$remap_models[model.name]]]
      next
    end

    original_id = record.id

    ## update foreign keys (ie user_id, page_id, group_id, etc)
    foreign_keys(record, associations).each do |foreign_key_type, foreign_key_column|
      record[foreign_key_column] = new_foreign_key(record, foreign_key_type, foreign_key_column)
    end

    ## save record
    begin
      if !model.column_names.include?('type') or record.read_attribute('type').nil?
        klass = model
      else
        klass = record.read_attribute('type').constantize
      end

      newrecord = klass.new(record.attributes)

      if model.column_names.include?('id')
        newrecord.id = record[:id] + $max_ids[model.class_name] 
      end
      if model.column_names.include?('type')
        newrecord.type = record[:type]
      end
      if model.column_names.include?('site_id')
        newrecord.site_id = $site_id
      end

      #puts '%s + %s = %s' % [record[:id], $max_ids[model.class_name], newrecord.id]

      if !newrecord.valid?
        # attempt to fix the problem if we can:
        newrecord.errors.each do |attribute, message|
          newrecord.fix_merge_error(attribute, message) if newrecord.respond_to?(:fix_merge_error)
        end
        if newrecord.respond_to?(:skip) and newrecord.skip
          puts 'SKIP %s:' % model.name
          p newrecord; puts
          next
        elsif !newrecord.valid?
          puts '-'*80; puts
          puts newrecord.errors.full_messages; puts
          p newrecord; puts
          debugger
          next
        end
      end

      newrecord.save
      putc '.'; STDOUT.flush()
      if newrecord.is_a? Asset and !File.exists?(newrecord.private_filename)
        puts "sync %s --> %s" % [asset_path(original_id), File.dirname(newrecord.private_filename)]
        system('rsync', '-r', asset_path(original_id)+'/', File.dirname(newrecord.private_filename))
      end
    rescue Exception => exc
      p exc
      debugger
    end
  end
end


ActiveRecord::Base.establish_connection $database_to

ThinkingSphinx.deltas_enabled = false
Page.all.each do |page|
  print "#{page.id} "; STDOUT.flush
  page.update_page_terms
end
ThinkingSphinx.deltas_enabled = true

Asset.find(:all).each do |asset|
  if asset.page
    print "#{asset.id} "; STDOUT.flush
    Asset.connection.execute('UPDATE assets SET page_terms_id = %s WHERE id = %s' % [asset.page.page_terms.id, asset.id])
  end
end

