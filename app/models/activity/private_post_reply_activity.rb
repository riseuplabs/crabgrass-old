class PrivatePostReplyActivity < PrivatePostActivity

  def description(view)
    super(view, :message_link_text => 'a reply'[:a_reply_link])
  end

end

