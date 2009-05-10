class MessageReplyActivity < MessagePageActivity
  alias_attr :post_id, :message_id
  def description(options={})
    # since the access is PRIVATE we know user is current_user.
    begin
      post = Post.find(self.post_id)
      page = post.discussion.page
    rescue ActiveRecord::RecordNotFound
      return "You received {message_tag} from {other_user}: {title}"[
       :activity_message_received,
       {:message_tag => "a reply",
        :other_user => user_span(:other_user),
        :title => ""}
      ]
    end
      page_link = content_tag(:a,'a reply'[:a_reply_link],
                             :href => "/#{page.owner_name}/#{page.friendly_url}")
      title = content_tag(:span,page.title,:class => 'message')
      return "You received {message_tag} from {other_user}: {title}"[
       :activity_message_received,
       {:message_tag => page_link,
        :other_user => user_span(:other_user),
        :title => post.body[0..20]+(post.body.size <=20 ? '' : '...')}
      ]

  end
end
