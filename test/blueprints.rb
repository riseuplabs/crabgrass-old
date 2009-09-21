require 'machinist/active_record'
require 'sham'
require 'faker'

# 
# Common
#

def created_date(average_days = 30)
  (average_days + 5 + rand(5)).days.ago.to_s(:db)
end

def updated_date(average_days = 30)
  (average_days + rand(5)).days.ago.to_s(:db)
end

def boolean
  rand(2) == 1 ? true : false
end

Sham.title            { Faker::Lorem.sentence }
Sham.email            { Faker::Internet.email }
Sham.login            { Faker::Internet.user_name.gsub(/[^a-z]/, "") }
Sham.display_name     { Faker::Name.name }
Sham.salt             { Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{Sham.login}--") }  
Sham.crypted_password { Digest::SHA1.hexdigest("--#{Sham.salt}--#{Sham.login}--") }
Sham.summary          { Faker::Lorem.paragraph }

# 
# Users
#

User.blueprint do
  login 
  display_name
  email
  salt
  crypted_password

  created_at        { created_date }
  last_seen_at      { updated_date }
end

# 
# Pages
#

# This method is useful to make Pages owned by Users or Groups whitout to have to pass all attributes 
# only passing the user or group instance and optional attributes
def Page.make_page_owned_by(object, attributes = {})
  raise "object needs to be an User or Group" if object.class != User || object.class != Group
  attributes.merge!({:owner_type => object.class.to_s, :owner_id => object.id, :owner_name => object.display_name})
  Page.make(attributes)
end

# By default we allways make pages with this blueprint owned by users
# if you want make pages owned by groups or users with specific attributes
# check out make_page_owned_by method
Page.blueprint do
  title
  summary
  created_at        { created_date }
  updated_at        { updated_date }
  stars_count       { 0 }
  views_count       { rand(100) }
  resolved          { boolean }

  u = User.make
  updated_by_login  u.login
  updated_by_id     u.id
  owner_type        "User"
  owner_id          u.id
  owner_name        u.display_name  

  type              "DiscussionPage"
end