# 
# Where do pages come from? The PageStork, of course!
# Here in lies all the reusable macros for creating complex pages
#


class PageStork
 
  def self.request_to_join_group(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    page = Tool::Request.new do |p|
      p.title = 'Request to join %s from %s'.t % [group.name, user.login]
      p.resolved = false
      p.data = Poll::Request.new do |r|
        r.action = Actions::AddToGroup.new(user,group)
        r.name = 'Add user %s to group %s?'.t % [user.login, group.name]
      end
    end
    page.add(group)
    page.add(group.users)
  end
  
  def self.join_sent_notice(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    info = Tool::Info.new do |i|
      i.title = 'Request sent to join %s'.t % group.name
      i.summary = 'You requested to join group %s at %s' % [group.name, Time.now]
    end
    info.add(user, :access => ACCESS_ADMIN)
  end
  
  def self.invite_to_join_group(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    from = options.delete(:from).cast! User
    page = Tool::Request.new do |p|
      p.title = 'Invitation to join group %s from user %s'.t % [group.name, from.login]
      p.resolved = false
      p.data = Poll::Request.new do |r|
        r.action = Actions::AddToGroup.new(user,group)
        r.name = 'Join group %s?' / group.name
      end
    end
    page.add(user, :access => ACCESS_ADMIN)
  end

  def self.request_for_contact(options)
    user = options.delete(:user).cast! User
    contact = options.delete(:contact).cast! User
    page = Tool::Request.new do |p|
      p.title = 'Contact invitation from %s' / user.login
      p.resolved = false
      p.data = Poll::Request.new do |r|
        r.action = Actions::AddToContacts.new(user,contact)
        r.name = 'Add user %s to your contact list?' / user.login
      end
    end
    page.add(contact, :access => ACCESS_ADMIN)
  end
  
  def self.contact_sent_notice(options)
    user = options.delete(:user).cast! User
    contact = options.delete(:contact).cast! User
    info = Tool::Info.new do |i|
      i.title = 'Contact request sent to user %s'.t % contact.login
      i.summary = 'Your request to add user %s as a contact has been sent. If %s approves the request, then you will also be added to the contact list of %s.' % ([contact.login]*3)
    end
    info.add(user, :access => ACCESS_ADMIN)
  end
  
  def self.private_message(options)
    from = options.delete(:from).cast! User
    to = options.delete(:to).cast! User
    page = Tool::Message.new do |p|
      p.title = 'Message from %s to %s' % [from.login, to.login]
      p.created_by = from
    end
    page.add(from, :access => ACCESS_ADMIN)
    page.add(to, :access => ACCESS_ADMIN)
  end
  
  def self.wiki(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    name = options.delete(:name).cast! String
    page = Tool::TextDoc.new do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
    end
    page.add(group)
    if options[:body]
      page.data = Wiki.new(:body => options[:body], :page => page)
    end
    return page
  end
  
end
