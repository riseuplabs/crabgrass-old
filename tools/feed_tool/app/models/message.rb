

  # A Message object just exists for the time from when it is created until it is
  # sent. This is either immediately (digest_setting == 0) or when digests are sent.
  # `tries' is 0 by default and gets incremented on every failed delivers, until the
  # maximum number of tries is used.
  #
  # Digests are sent by a rake task that does basically the following:
  # find all messages with digest >= DIGEST_SETTINGS[:daily]
  # deliver messages (success => delete message ; failure => increment tries)
  #
  # == Database
  #
  # create_table :messages do |t|
  #   t.integer :digest_setting
  #   t.integer :user_id
  #   t.integer :account_id
  #   t.integer :tries
  #   t.text :data
  # end
  class Message < ActiveRecord::Base
    DIGEST_SETTINGS = { :now => 0, :daily => 1, :weekly => 2 }
    
    #acts_as_cool!
    
    belongs_to :user
    belongs_to :account
    
    #acts_as_stoned
    
    named_scope(:daily) do 
      { :conditions => ['digest_setting <= ?', DIGEST_SETTINGS[:daily]] } # { :digest_setting => DIGEST_SETTINGS[:daily] }}
    end
    named_scope(:now) do 
      { :conditions => ['digest_setting <= ?', DIGEST_SETTINGS[:now]] } # { :digest_setting => DIGEST_SETTINGS[:now] }}
    end
    named_scope(:weekly) do 
      {:conditions => ['digest_setting <= ?', DIGEST_SETTINGS[:weekly]]} # { :digest_setting => DIGEST_SETTINGS[:weekly] }}
    end
    
    def deliver
      begin
        self.account.send_message(self.mail)
        self.destroy
      rescue
        self.increment! :tries
      end
    end
    
    def mail
      TMail::Mail.parse(self.data)
    end
  end

  
#   def self.instances
#     a = []
#     ObjectSpace.each_object { |o|
#       a << o if o.class == self
#     };a
#   end
