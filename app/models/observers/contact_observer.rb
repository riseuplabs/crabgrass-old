class ContactObserver < ActiveRecord::Observer

  def after_create(contact)
    if activity = ContactActivity.find_twin(contact.user, contact.contact)
      key = activity.key
    else
      key = rand(Time.now)
    end
    ContactActivity.create!(:user => contact.user, :other_user => contact.contact, :key => key)
  end

end

