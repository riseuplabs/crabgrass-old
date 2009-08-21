#
#  create_table "user_settings", :force => true do |t|
#    t.integer  "user_id",                    :limit => 11
#    t.string   "email_address"
#    t.string   "sms_number"
#    t.string   "sms_carrier"
#    t.string   "im_address"
#    t.string   "im_type"
#    t.boolean  "allow_insecure_email",                     :default => false
#    t.boolean  "allow_insecure_im",                        :default => false
#    t.boolean  "allow_insecure_sms",                       :default => false
#    t.integer  "email_crypt_key_id",         :limit => 11
#    t.integer  "sms_crypt_key_id",           :limit => 11
#    t.boolean  "email_allowed",                            :default => true
#    t.boolean  "sms_allowed",                              :default => false
#    t.boolean  "im_allowed",                               :default => false
#    t.boolean  "receive_digest",                           :default => true
#    t.integer  "digest_frequency",           :limit => 11, :default => 2
#    t.integer  "digest_day",                 :limit => 11
#    t.integer  "preferred_reception_method", :limit => 11, :default => 1
#    t.string   "languages_spoken"
#    t.integer  "level_of_expertise",         :limit => 11
#    t.boolean  "show_welcome",                             :default => true
#    t.integer  "login_landing",              :limit => 11, :default => 0
#    t.datetime "created_at"
#    t.datetime "updated_at"
#  end
#

class UserSetting < ActiveRecord::Base

  belongs_to :user

  ##
  ## CONSTANTS
  ##

  # update digest frequency
  DIGEST = {:daily => 0, :twice_weekly => 1, :weekly => 2, :twice_monthly => 3, :monthly => 4}.freeze

  # preferred notificatin reception method
  METHOD = {:none => 0, :email => 1, :sms => 2, :im => 3}.freeze

  # level of expertise / how much help to show
  EXPERTISE = {:low => 0, :medium => 1, :high => 2}.freeze

  # when you first login, where do you go?
  LANDING = {:dashboard => 0, :site_home => 1}.freeze

  # which editor to use by default.
  EDITOR = {:greencloth => 0, :html => 1, 0 => :greencloth, 1 => :html}.freeze

  def preferred_editor_sym
    EDITOR[preferred_editor]
  end

  def preferred_editor_sym=(value)
    self.preferred_editor = EDITOR[value.to_sym]
  end

  def preferred_editor
    read_attribute('preferred_editor') || case Conf.text_editor_sym
      when :greencloth_only then 0
      when :html_only then 1
      when :greencloth_preferred then 0
      when :html_preferred then 1
    end
  end

end

