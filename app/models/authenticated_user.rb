require 'crypt'

class AuthenticatedUser < ActiveRecord::Base
  set_table_name "users"
	  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  # the current authenticated user object
  cattr_accessor :current
  
  validates_presence_of     :username
  validates_uniqueness_of   :username
  validates_length_of       :username, :within => 3..40
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?

  before_save :encrypt_password
  
  # Authenticates a user by their username and unencrypted password.
  # Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_username(login)
    u && u.authenticated?(password) ? u : nil
  end

  # return true if password matches. can use either old crypt(3) style hash
  # or newer crypt+md5 style hash used by /etc/shadow files. we do this so
  # you can import existing user databases (as long as they use crypt).
  def authenticated?(password)
    if crypted_password =~ /^\$/
      return Crypt.check(password, crypted_password)
    else
      return password.crypt(crypted_password[0..1]) == crypted_password
    end
  end

  protected
  
  # used to skip password validations when password is not changed or already set.
  def password_required?
    crypted_password.blank? or not password.blank?
  end

  # called before save
  def encrypt_password
    return if password.blank?
    self.crypted_password = Crypt.crypt(password)
  end

end
