# 
# Where do pages come from? The PageStork, of course!
# Here in lies all the reusable macros for creating complex pages
#


class PageStork
 
  def self.request_to_join_group(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    page = Page.new do |p|
      p.title = 'Request to join %s from %s'.t % [group.name, user.login]
      p.needs_attention = true
      p.tool = Poll::Request.new do |r|
        r.action = Actions::AddToGroup.new(user,group)
        r.name = 'Add user %s to group %s?'.t % [user.login, group.name]
      end
    end
    page.add(group)
  end
  
  def self.invite_to_join_group(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    from = options.delete(:from).cast! User
    page = Page.new do |p|
      p.title = 'Invitation to join group %s from user %s'.t % [group.name, from.login]
      p.needs_attention = true
      p.tool = Poll::Request.new do |r|
        r.action = Actions::AddToGroup.new(user,group)
        r.name = 'Join group %s?' / group.name
      end
    end
    page.add(user)
  end

  def self.request_for_contact(options)
    user = options.delete(:user).cast! User
    contact = options.delete(:contact).cast! User
    page = Page.new do |p|
      p.title = 'Contact invitation from %s' / user.login
      p.needs_attention = true
      p.tool = Poll::Request.new do |r|
        r.action = Actions::AddToContacts.new(user,contact)
        r.name = 'Add user %s to your contact list?' / user.login
      end
    end
    page.add(contact)
  end
  
  
end
