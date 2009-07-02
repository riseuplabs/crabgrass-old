#
# A script to merge two crabgrass databases. 
#

# stuff to configure

$database_from = {
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "crabgrass",
  :password => "ien1Zei2",
  :database => "stopx"
}

$database_to = :production    # whatever is configured in database.yml

$site_id = 1
$from_asset_dir = '/usr/apps/crabgrass/stopx/assets'

# stuff that should not need changing

$exclude_models = %w(Language Tracking PageTerms Site AssetVersion)

# the code

def get_models
  tables = []
  ActiveRecord::Base.send(:subclasses).each do |klass|
    next unless klass.table_exists?
    next if $exclude_models.include?(klass.class_name)
    tables << klass
    #foreign_key_columns = klass.columns - klass.content_columns
    #column_names = foreign_key_columns.collect{|column|column.name}.grep /_id$/
    #tables[klass] = column_names
  end
  return tables
end

def get_max_ids(models)
  hsh = {}
  models.each do |model|  
    hsh[model.class_name] = model.maximum(:id) + 1
  end
  return hsh
end

desc "merge two databases." 
task :merge_databases => :environment do
  ActiveRecord::Base.establish_connection $database_from
  models = get_models
  users_from = User.find(:all)
  groups_from = Group.find(:all)
  
  ActiveRecord::Base.establish_connection $database_to
  max_ids = get_max_ids(models)

  user_ids = {}  # {from_id => to_id}
  group_ids = {} # {from_id => to_id}
  users_from.each do |user_from|
    user_to = User.find_by_login(user_from.login)
    user_ids[user_from.id] = user_to.id if user_to
  end
  groups_from.each do |group_from|
    group_to = Group.find_by_name(group_from.name)
    group_ids[group_from.id] = group_to.id if group_to
  end

  ActiveRecord::Base.record_timestamps = false
  ThinkingSphinx.updates_enabled = false

  models.each do |model|
    puts    
    puts ':::::::::::::: ' + model.class_name + ' :::::::::::::::'
    puts
    model.class_eval do |base|
      base.write_inheritable_attribute("attr_protected", nil)
      base.write_inheritable_attribute("attr_accessible", nil)
    end

    ##
    ## EXPORT THE DATA
    ##

    ActiveRecord::Base.establish_connection $database_from

    records = model.find(:all)

    ##
    ## IMPORT THE DATA
    ##

    ActiveRecord::Base.establish_connection $database_to

    associations = model.reflect_on_all_associations.select do |association|
      association.macro == :belongs_to
    end

    records.each do |record|
      if model == User and user_ids[record.id]
        puts 'skipping user %s' % record.login
        next
      elsif model == Group and group_ids[record.id]
        puts 'skipping group %s' % record.name
        next
      end

      original_id = record.id

      ## update foreign keys
      associations.each do |association|
        foreign_key = association.primary_key_name
        foreign_type = if association.options[:foreign_type]
          record.send(association.options[:foreign_type])
        else
          association.klass.class_name
        end
        #p [foreign_key, foreign_type, max_ids[foreign_type]]

        if foreign_type == "Group"
          record[foreign_key] = group_ids[record[foreign_key]] || record[foreign_key]
        elsif foreign_type == "User"
          record[foreign_key] = user_ids[record[foreign_key]] || record[foreign_key]
        else
          if !record[foreign_key].nil? and max_ids[foreign_type]
            record[foreign_key] += max_ids[foreign_type]
          end
        end
      end

      ## update other keys
      record[:site_id] = $site_id if record.respond_to? :site_id=

      ## save record
      newrecord = model.new record.attributes
      newrecord.id = record[:id] + max_ids[model.class_name]

      if !newrecord.valid?
        puts '-'*80
        puts
        puts newrecord.errors.full_messages
        puts
        p newrecord
        puts
      else
        newrecord.save
        putc '.'; STDOUT.flush()
        if model.is_a? Asset
          puts "moving %s --> %s" % ["#{$from_asset_dir}/0000/#{original_id}", File.dirname(newrecord.private_filename)]
          File.rename("#{$from_asset_dir}/0000/#{original_id}", File.dirname(newrecord.private_filename))
        end
      end
      puts

    end
  end
end

