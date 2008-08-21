#!/usr/bin/ruby

require 'mysql'
require 'yaml'

# get config values from yaml file
begin
  config = YAML::load_file('config/database.yml')
rescue => e
  puts "Configuration file not found or you don't have enough permissions to read it."
  puts "Error message: #{e.error}"
  exit 1
end

db_host = config['development']['host']
db_name = config['development']['database']
db_user = config['development']['username']
db_pwd  = config['development']['password']

# connect to the MySQL server
begin
  dbh = Mysql.new(db_host, db_user, db_pwd, db_name)
  dbh.query("set character_set_connection = 'utf8'")
  dbh.query("set character_set_client = 'utf8'")
  dbh.query("set character_set_results = 'utf8'")

rescue Mysql::Error => e
  puts "Couldn't connect to MySQL server."
  puts "Error code: #{e.errno}"
  puts "Error message: #{e.error}"
  exit 1
end

# get the languages
lang_id = {}
res = dbh.query("SELECT `code`, `id` FROM `languages`")
res.each {|row| lang_id[row[0]] = row[1].to_i}
res.free

# get the keys
key_id = {}
res = dbh.query("SELECT `name`, `id` FROM `keys`")
res.each {|row| key_id[row[0]] = row[1].to_i}
res.free

# get the translations
trans = {}
lang_id.each_key {|k| trans[k] = {} }

lang_id.each do |lcode,lid|
  key_id.each do |kname,kid|
    res = dbh.query("SELECT `text` FROM `translations` WHERE `language_id` = #{lid} AND `key_id` = '#{kid}'")
    res.each {|row| trans[lcode][kname] = row[0]}
    res.free
  end
end

# write a YAML file for translation
trans.each do |lang,translations|
  buffer = []
  translations.each do |key, translation|
    buffer << "#{key}: #{translation}\n"
  end
  File.open('lang/' + lang, 'w') {|f| f.write(buffer) }
end
