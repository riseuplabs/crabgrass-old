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

Sham.title            { Faker::Lorem.words(3).join(" ").capitalize }
Sham.email            { Faker::Internet.email }
Sham.login            { Faker::Internet.user_name.gsub(/[^a-z]/, "") }
Sham.display_name     { Faker::Name.name }
Sham.summary          { Faker::Lorem.paragraph }
Sham.caption          { Faker::Lorem.words(5).join(" ") }

#
# Site
#
Site.blueprint do
  # make sites available from functional tests
  domain       "test.host"
  email_sender "robot@$current_host"
end

#
# Users
#
User.blueprint do
  login
  display_name
  email
  salt              { Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") }
  crypted_password  { Digest::SHA1.hexdigest("--#{salt}--#{login}--") }

  created_at        { created_date }
  last_seen_at      { updated_date }
end

#
# Groups
#

# requires :user
def Group.make_owned_by(attributes)
  raise "Missing keys (:user) are required for this blueprint" if !attributes.has_key?(:user)
  user = attributes.delete :user
  group = Group.make_unsaved(attributes)
  group.created_by = user
  group.save!
  group
end

Group.blueprint do
  full_name       { Sham.display_name }
  name            { full_name.gsub(/[^a-z]/,"") }
  site            { Site.first || Site.make }
end

Committee.blueprint do
  name            { Sham.title.gsub(/[^a-z]/,"")[0, 10] }
end

Council.blueprint do
end

Network.blueprint do
  full_name       { Sham.display_name }
  name            { full_name.gsub(/[^a-z]/,"") }
end

def Committee.make_for(attributes)
  raise "Missing keys (:group) are required for this blueprint" if !attributes.has_key?(:group)
  group = attributes.delete :group
  committee = Committee.make(attributes)
  group.add_committee!(committee)
end

Committee.blueprint do
  name       { Sham.login }
end

def Council.make_for(attributes)
  raise "Missing keys (:group) are required for this blueprint" if !attributes.has_key?(:group)
  group = attributes.delete :group
  committee = Council.make(attributes)
  group.add_committee!(committee)
end

Council.blueprint do
  name       { Sham.login }
end

#
# Pages
#

# requieres :owner in attributes
def Page.make_owned_by(attributes, machinist_attributes = {})
  page = Page.make_unsaved(machinist_attributes)
  attributes.reverse_merge!(page.attributes)
  page = Page.build!(attributes)
  page.save!
  page.reload
end

# By default we always make pages with this blueprint owned by users
# if you want make pages owned by groups or users with specific attributes
# check out make_page_owned_by method
def make_a_page
  title
  summary
  created_at        { created_date }
  updated_at        { updated_date }
  stars_count       { 0 }
  views_count       { rand(100) }
  resolved          { boolean }
end

WikiPage.blueprint do
  make_a_page
end

DiscussionPage.blueprint do
  make_a_page
end

Gallery.blueprint do
  make_a_page
end

Showing.blueprint {}

Page.blueprint do
  make_a_page
end

AssetPage.blueprint do
  make_a_page
end

#
# Asset
#

def make_an_asset
  created_at    { created_date }
  updated_at    { updated_date }
  caption
  version       { 1 }
  parent_page   { AssetPage.make }
end

Asset.blueprint do
  make_an_asset
end

ImageAsset.blueprint do
  make_an_asset
  content_type  { "image/jpeg" }
  height        { 500 }
  width         { 333 }
  filename      { "bee.jpg" }
  size          { 100266 }
  is_image      { true }
end


#
# UserParticipation
#
UserParticipation.blueprint do
  access  1
  watch   false
end

#
# GroupParticipation
#
GroupParticipation.blueprint do
  access  1
end

#
# Wiki
#
Wiki.blueprint do
  version 1
  body_html { Faker::Lorem.paragraph }
  body  { body_html }
  user_id { User.make.id }
end

#
# Others
#
RateManyPage.blueprint {}

Poll.blueprint {}
RankingPoll.blueprint {}
RatingPoll.blueprint {}

Discussion.blueprint {}

# requieres :page in attributes
def Post.make_comment_to(attributes, machinist_attributes = {})
  post = Post.make_unsaved(machinist_attributes)
  attributes.reverse_merge!(post.attributes)
  attributes.merge! :page => page
  post = Post.build! attributes
  page.save!
  page.reload
end

Post.blueprint do
  discussion { Discussion.make }
  body       { Faker::Lorem.paragraph }
  user       { User.make }
end

if Conf.mod_enabled? 'moderation'
  ModeratedFlag.blueprint do
    reason_flagged  { "language" }
    comment         { Faker::Lorem.paragraph }
    created_at      { updated_date(5) } # this should be newer than the page
    user            { User.make }
    type            { "ModeratedFlag" }
  end

end
