module ThinkingSphinx
  class Configuration
    attr_accessor :config_file, :searchd_log_file, :query_log_file,
      :pid_file, :searchd_file_path, :address, :port, :allow_star
    attr_reader :environment
    
    def initialize
      @environment = ENV['RAILS_ENV'] || "development"
      
      self.config_file       = "#{RAILS_ROOT}/config/#{environment}.sphinx.conf"
      self.searchd_log_file  = "#{RAILS_ROOT}/log/searchd.log"
      self.query_log_file    = "#{RAILS_ROOT}/log/searchd.query.log"
      self.pid_file          = "#{RAILS_ROOT}/log/searchd.#{environment}.pid"
      self.searchd_file_path = "#{RAILS_ROOT}/db/sphinx/#{environment}/"
      self.port              = 3312
      self.allow_star        = false
      
      parse_config
    end
    
    # Generate the config file for Sphinx. This has the following default
    # settings, relative to RAILS_ROOT where relevant:
    #
    # config file::      config/#{environment}.sphinx.conf
    # searchd log file:: log/searchd.log
    # query log file::   log/searchd.query.log
    # pid file::         log/searchd.#{environment}.pid
    # searchd files::    db/sphinx/#{environment}/
    # address::          0.0.0.0 (all)
    # port::             3312
    # allow star::       false
    #
    # If you want to change these settings, create a YAML file at
    # config/sphinx.yml with settings for each environment, in a similar
    # fashion to database.yml - using the following keys: config_file,
    # searchd_log_file, query_log_file, pid_file,
    # searchd_file_path, port, allow_star.
    # 
    # Each setting is optional, so only add the ones you want to change from
    # the defaults.
    #
    # Note: allow_star should not be set to true unless using sphinx 0.9.8 r871
    # or later.
    #
    def build(file_path=nil)
      load_models
      file_path ||= "#{self.config_file}"
      database_conf = YAML.load(File.open("#{RAILS_ROOT}/config/database.yml"))[environment]
      
      open(file_path, "w") do |file|
        file.write <<-CONFIG
indexer
{
  mem_limit = 64M
}

searchd
{
  port = #{self.port}
  log = #{self.searchd_log_file}
  query_log = #{self.query_log_file}
  read_timeout = 5
  max_children = 30
  pid_file = #{self.pid_file}
}
        CONFIG
        
        ThinkingSphinx.indexed_models.each do |model|
          sources         = []
          prefixed_fields = []
          infixed_fields  = []
          
          model.indexes.each_with_index do |index, i|
            attr_sources = index.attributes.collect { |attrib|
              if attrib.timestamp?
                "sql_attr_timestamp  = #{attrib.unique_name}"
              else
                "sql_group_column = #{attrib.unique_name}"
              end
            }.join("\n  ")
            
            file.write <<-SOURCE

source #{model.name.downcase}_#{i}_core
{
  type = mysql
  sql_host = #{database_conf["host"] || "localhost"}
  sql_user = #{database_conf["username"]}
  sql_pass = #{database_conf["password"]}
  sql_db   = #{database_conf["database"]}

  sql_query_pre    = #{index.sql_query_pre}
  sql_query        = #{index.to_sql.gsub(/\n/, ' ')}
  sql_query_range  = #{index.sql_query_range}
  sql_query_info   = #{index.sql_query_info}
  #{attr_sources}
}
            SOURCE
            
            if index.delta?
              file.write <<-SOURCE

source #{model.name.downcase}_#{i}_delta : #{model.name.downcase}_#{i}_core
{
  sql_query_pre    = 
  sql_query        = #{index.to_sql(true).gsub(/\n/, ' ')}
  sql_query_range  = #{index.sql_query_range true}
}
              SOURCE
            end
            sources << "#{model.name.downcase}_#{i}_core"
          end
          
          source_list = sources.collect { |s| "source = #{s}" }.join("\n")
          delta_list  = source_list.gsub(/_core$/, "_delta")
          file.write <<-INDEX

index #{model.name.downcase}_core
{
  #{source_list}
  morphology = stem_en
  path = #{self.searchd_file_path}/#{model.name.downcase}_core
  charset_type = utf-8
  INDEX
          if self.allow_star
            file.write <<-INDEX
  enable_star    = 1
  min_prefix_len = 1
            INDEX
          end
          
          file.write("}\n")
          
          if model.indexes.any? { |index| index.delta? }
            file.write <<-INDEX

index #{model.name.downcase}_delta : #{model.name.downcase}_core
{
  #{delta_list}
  path = #{self.searchd_file_path}/#{model.name.downcase}_delta
}

index #{model.name.downcase}
{
  type = distributed
  local = #{model.name.downcase}_core
  local = #{model.name.downcase}_delta
}
            INDEX
          else
            file.write <<-INDEX
index #{model.name.downcase}
{
  type = distributed
  local = #{model.name.downcase}_core
}
            INDEX
          end
        end
      end
    end
    
    private
    
    # Make sure all models are loaded
    def load_models
      Dir[RAILS_ROOT + "/app/models/**/*.rb"].each do |file|
        model_name = file.gsub(/^.*\/([\w_]+)\.rb/, '\1')
        next if model_name.nil?
        begin
          model_name.camelize.constantize
        rescue NameError
          next
        end
      end
    end
    
    def parse_config
      path = "#{RAILS_ROOT}/config/sphinx.yml"
      return unless File.exists?(path)
      
      conf = YAML.load(File.open(path))[environment]
      
      conf.each do |key,value|
        self.send("#{key}=", value) if self.methods.include?("#{key}=")
      end unless conf.nil?
    end
  end
end