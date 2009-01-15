module UserExtension

  # We need a hostname in order to construct a Jabber ID for each user.
  DOMAIN = 'localhost'

  # Redefine the habtm relationship
  # so it calls the 'after_add' and 'after_remove' callbacks.
  def self.add_to_class_definition
    lambda do
      has_and_belongs_to_many :contacts,
        {:class_name => "User",
        :join_table => "contacts",
        :association_foreign_key => "contact_id",
        :foreign_key => "user_id",
        :after_add => :create_user_roster_and_group_roster,
        :after_remove => :destroy_user_roster_and_group_roster,
        :uniq => true} do
          # TODO: We should ask ejabberd which users are online
          def online
            find( :all, 
              :conditions => ['users.last_seen_at > ?',10.minutes.ago],
              :order => 'users.last_seen_at DESC' )
          end
      end
    end
  end

  module InstanceMethods
    def create_user_roster_and_group_roster(contact)
      
      user_roster_data  = { :username     => self.login,
                            :jid          => "#{contact.login}@#{DOMAIN}",
                            :subscription => 'B',
                            :ask          => 'N',
                            :server       => 'N',
                            :type         => 'item'}
      if UserRoster.create!(user_roster_data)
        logger.warn("XXXXXXXXXX")
      end

      group_roster_data  = { :username     => self.login,
                             :jid          => "#{contact.login}@#{DOMAIN}",
                             :grp          => "Contacts" }
      GroupRoster.create!(group_roster_data)
    end

    def destroy_user_roster_and_group_roster(contact)
      conditions = { :username => self.login,
                     :jid => "#{contact.login}@#{DOMAIN}" }

      # Find the UserRoster of this contact.
      user_roster = UserRoster.find(:first, :conditions => conditions)
      # And destroy it.
      user_roster.destroy

      # Find the GroupRoster of this contact.
      group_roster = GroupRoster.find(:first, :conditions => conditions)
      # And destroy it too.
      group_roster.destroy
    end
  end
end
