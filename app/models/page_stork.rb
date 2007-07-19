# 
# Where do pages come from? The PageStork, of course!
# Here in lies all the reusable macros for creating complex pages
#


class PageStork

  def self.bold(*args)
    args.collect do |a|
      "<b>#{a}</b>"
    end
  end
  
  def self.request_to_join_group(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    page = Tool::Request.new do |p|
      p.title = 'request to join %s from %s'.t % [group.name, user.login]
      p.resolved = false
      p.flow = FLOW[:membership]
      p.data = Poll::Request.new do |r|
        r.action = Actions::AddToGroup.new(user,group)
        r.name = 'Add user %s to group %s?'.t % bold(user.login, group.name)
      end
    end
    page.add(group)
    page.add(group.users)
  end
  
  def self.join_discussion(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    page = Tool::RequestDiscussion.new do |p|
      p.title = 'discussion re: request to join %s from %s'.t % [group.name, user.name]
      p.summary = 'User %s has requested to join group %s. Both %s and %s have access to this page, so can use this space discuss the request.' % bold(user.name, group.name, user.name, group.name)
      p.flow = FLOW[:membership]
      p.resolved = false
    end
    page.add(user, :access => :admin)
    page.add(group, :access => :admin)
    if options[:message].any?
      page.build_post(options[:message],user)
    end
    page
  end
  
  def self.invite_to_join_group(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    from = options.delete(:from).cast! User
    page = Tool::Request.new do |p|
      p.title = 'invitation to join group %s'.t % group.name
      p.resolved = false
      p.flow = FLOW[:membership]
      p.data = Poll::Request.new do |r|
        r.action = Actions::AddToGroup.new(user,group)
        r.name = 'Join group %s?'.t % bold(group.name)
      end
    end
    page.add(user, :access => :admin)
  end

  def self.invite_discussion(options)
    user = options.delete(:user).cast! User
    group = options.delete(:group).cast! Group
    from = options.delete(:from).cast! User
    page = Tool::RequestDiscussion.new do |p|
      p.title = 'discussion re: invitation to join group %s'.t % [group.name]
      p.summary = 'User %s has sent %s an invitation to join group %s. Both %s and %s have access to this page, you can use this space discuss the request.' % bold(from.name, user.name, link_to_group(group), group.name, user.name)
      p.flow = FLOW[:membership]
      p.resolved = false
    end
    page.add(group, :access => :admin)
    page.add(user, :access => :admin)
    if options[:message].any?
      page.build_post(options[:message],from)
    end
    page
  end



  def self.request_for_contact(options)
    user = options.delete(:user).cast! User
    contact = options.delete(:contact).cast! User
    page = Tool::Request.new do |p|
      p.title = 'contact invitation from %s to %s'.t % [user.login, contact.login]
      p.resolved = false
      p.data = Poll::Request.new do |r|
        r.action = Actions::AddToContacts.new(user,contact)
        r.name = 'Add user %s to your contact list?' % bold(user.login)
      end
      p.flow = FLOW[:contacts]
    end
    page.add(contact, :access => :admin)
    #if options[:message].any?
    #  page.build_post(options[:message],user)
    #end
    page
  end
  
  def self.contact_discussion(options)
    user = options.delete(:user).cast! User
    contact = options.delete(:contact).cast! User
    info = Tool::RequestDiscussion.new do |i|
      i.title = 'discussion re: contact invitation from %s to %s'.t % [user.name, contact.name]
      i.summary = 'User %s has sent a contact invitation to %s. Both people have access to this page, so you can use this space discuss the request.' % bold(user.name, contact.name)
      i.flow = FLOW[:contacts]
      i.resolved = false
    end
    info.add(user, :access => :admin)
    info.add(contact, :access => :admin)
    if options[:message].any?
      info.build_post(options[:message],user)
    end
    info
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
  
  def self.private_message(options) 
    from = options.delete(:from).cast! User 
    to = options.delete(:to) 
    page = Tool::Message.new do |p| 
      p.title = options[:title] || 'Message from %s to %s' % [from.login, to.login] 
      p.created_by = from 
      p.discussion = Discussion.new 
      post = Post.new(:body => options[:body]) 
      post.discussion = p.discussion 
      post.user = from 
      p.discussion.posts << post 
    end 
    page.add(from, :access => :admin) 
    page.add(to, :access => :admin) 
    page 
  end
  
end
