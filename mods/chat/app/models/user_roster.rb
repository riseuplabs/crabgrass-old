class UserRoster < ActiveRecord::Base
  # Ejabberd uses the column 'type' to hold information about a User Roster
  # So we set 'inheritance_column' to nil
  # in order to not collapse with Rails Single Table Inheritance mechanism.
  set_inheritance_column = nil

  set_table_name 'rosterusers'

  before_save :change_nils_to_empty_strings

  protected
  # Ejabberd schema defines these fields as NOT NULL
  # but reverse engineering shows them as being empty strings.
  # So we change change to empty strings if they are set to nil.
  def change_nils_to_empty_strings
    self.nick       ||= ''
    self.askmessage ||= ''
    self.subscribe  ||= ''
  end
end
