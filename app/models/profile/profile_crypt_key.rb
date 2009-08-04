require 'keyring'

class ProfileCryptKey < ActiveRecord::Base
  set_table_name 'crypt_keys'

  validates_presence_of_optional_attributes
  validates_presence_of :key

  belongs_to :profile

  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  def before_create
    keyring_path = "%s/%s.keystore" % [KEYRING_STORAGE, profile.user.id]
    keyring = Keyring.create(self.key, keyring_path)
    info = keyring.extract_info
    self.name = info[:email]
    self.fingerprint = info[:fingerprint]
    self.description = 'gpg'
    self.keyring = keyring.path
  end

  def icon
    'key'
  end

end

