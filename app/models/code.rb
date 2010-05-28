#
#  Page Access Code
#
#  Two uses:
#  (1) provide url obfuscation for links in email
#  (2) or, to give url or url+email access to a page
#
#  create_table :codes do |t|
#    t.string :code, :limit => 10
#    t.integer :page_id
#    t.integer :user_id
#    t.integer :access
#    t.datetime :expires_at
#    t.string :email
#    t.timestamps
#  end
#

require 'password'

class Code < ActiveRecord::Base
  belongs_to :user
  belongs_to :page

  def before_create
    begin
       self.code = Password.random(10)
    end until Code.find_by_code(self.code).nil?
    self.expires_at ||= Time.now + 30.days
    true
  end

  def self.cleanup_expired
    Code.delete_all ['expires_at < ?', Time.now.utc]
  end

  def days_left
    ((expires_at - Time.now) / 1.day).ceil
  end

  def to_param
    self.code
  end

end

