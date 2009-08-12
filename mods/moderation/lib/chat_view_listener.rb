class ChatViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def chat_channel_actions(context)
    return unless logged_in?
    url = url_for(:controller => 'yucky',
                  :id => context[:group].id,
                  :action => :add_chat)
    link = link_to_remote(:flag_inappropriate.t,
                          :url => url,
                          :complete => "Modalbox.show('<div>#{:chat_flagged_inappropriate.t}</div>', {title: '#{:flag_inappropriate.t}'})",
                          :confirm => :confirm_inappropriate_page.t)
    content_tag(:p, link, :class => 'small_icon sad_plus_16')
  end
end
