# = FeedrAccount
# FeedrAccount defines both a conventional interface, and common functionality
# to serve as a base class for Accounts, to be used with the BackgrounDRb
# :mail_worker Worker.
#
# For an example of how this class is used in practice, see MailAccount.
#
# == Database layout
# The table used with FeedrAccount usually looks like this:
#   create_table :feedr_accounts do |t|
#     t.string :type
#     t.text :credentials, :default => { }
#     t.text :receivers, :default => []
#     t.boolean :active, :default => false
#   end
#
# Explaination of fields:
# * type - STI field, don't touch!
# * credentials - all kind of login data, and / or settings the account needs.
#   usually this is a serialized Hash (default). See doc of the
#   `credentials' class method for a powerful - however not 
#   essentially needed interface.
# * receivers - this has to be a serialized array of symbols, that points to
#   (user-)enabled receivers for this account. See documentation
#   of receivers below for further details.
# * active - if set to true, the account will automatically be checked by the
#   BackgrounDRb worker periodically. This functionality can be overridden by
#   providing a custom check_for_messages? method.
# 
# == send/receive interface
# The interface depends on the following methods to be defined in the child
# class:
# * receive() - Receive message objects from server. Argument requirements
#   are not yet defined.
# * send_message(msg) - Send the given message object `msg'. The msg object is
#   required to bring all the needed information 
#
#
#
# == Receivers
# Once a message is received, the BackgrounDRb Worker :mail_worker will query
# the acting FeedrAccount instance for their receivers. This is done through
# the `enabled_receivers' method.
#
# A receiver is generally a block, which takes a Message as the only argument.
# A typical receiver might look like this:
#
#   receiver(:create_post) do |message|
#     post = Post.new
#     # ... some code to determine right attributes for post
#     post.save
#     # the return value of a receiver is generally ignored.
#     # error handling also needs to be taken care of in the
#     # receiver itself.
#   end
#
#
# 
class FeedrAccount < ActiveRecord::Base
  before_save :validate_credentials
  
  
  # dummy interface (you'll notice when you use it)
  def receive *args
    raise "Dummy method called."
  end
  
  def receivers
    self.read_attribute(:receivers) || self.write_attribute(:receivers, [])
  end
  
  # dito.
  def send_message *args
    raise "Dummy method called."
  end
  
  # credentials are dumped in YAML usually. this method loads them back into
  # form (by default i.e. Hash)
  def credentials
    creds = read_attribute(:credentials)
    if creds
      creds.kind_of?(String) ? YAML::load(creds) : creds
    else
      write_attribute(:credentials, {})
    end
  end
  
  def validate_credentials
    raise Exception.new("You need to specify required credentials in your model. If you don't insist to use any credentials (or manage them on your own) write a (possibly empty) `validate_credentials' method.")
  end
  
  # By default this method returns the value of the `receivers' field.
  def enabled_receivers
    YAML::load(self.receivers).map { |key| self.receivers[key] }.compact
  end
  
  # by default returns the result of self.active
  def check_for_messages?
    self.active
  end

  #
  # CLASS METHODS
  # 
  
  # call-seq: FeedrAccount::receiver(name) {|msg| ... }
  #
  # define a receiver, identified by the given name.
  # See Receivers documentation for details and examples.
  def self.receiver(name, &block)
    self.receivers[name] = block
  end
  
  # call-seq: FeedrAccount::receivers
  #
  # returns a Hash with all receivers, currently configured in this class.
  def self.receivers
    @@__receivers ||= {}
  end
  
  # call-seq: FeedrAccount::credentials(fields, ...)
  #
  # This method is used to create a powerful interface to the credentials hash.
  # It is given a bunch of symbols and creates getter and setter methods to 
  # store them in the credentials field.
  # 
  # Example:
  # This simple line of code:
  #   credentials :login, :password
  # is equivalent to the following:
  # 
  #   def login
  #     self.credentials[:login]
  #   end
  # 
  #   def login= value
  #     self.credentials[:login] = value
  #   end
  #
  #   def password
  #     self.credentials[:password]
  #   end
  # 
  #   def password= value
  #     self.credentials[:password] = value
  #   end
  # 
  #   def validate_credentials
  #     ([:login, :password] - self.credentials.keys).any?
  #   end
  #
  # The validate_credentials method is called as an ActiveRecord `before_save'
  # method, so all fields passed to `credentails' are by default required to 
  # to be set, in order to save the account.
  # To use optional arguments put them into a seperate Array as last argument.
  #
  # Example:
  # <code>credentials :login, :password, [:use_ssl, :salt]</code>
  # This way the :use_ssl and :salt fields are optional.
  #
  def self.credentials *fields
    optional = (fields.last.kind_of? Array) ? fields.pop : []
    (fields+optional).each do |field|
      # getter
      self.method(:define_method).call(field) do 
        self.credentials[field]
      end
      # setter
      self.method(:define_method).call((field.to_s+'=').to_sym) do |value|
        self.credentials[field] = value
      end
    end
    self.method(:define_method).call(:validate_credentials) do 
      if (missing = (fields - self.credentials.keys)).any?
        self.errors.add "You didn't provide all credentials. Missing: #{missing.join ', '}"
        false
      else
        true
      end
    end
  end
  
  class FeedrFailure < Exception
    attr :original_exception, true
  end
end


