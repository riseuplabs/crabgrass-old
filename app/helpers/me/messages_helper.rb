module Me::MessagesHelper

  def recipient_field(recipient_name)
    if recipient_name.blank?
      # input field
      recipient_name_text_field_tag(nil) + "\n" +
      # autocomplete js
      autocomplete_entity_tag('recipient_name', :url => '/autocomplete/recipients')
    else
      # show a label
      label_tag 'say_text', I18n.t(:message_recipient_name_caption, :user => recipient_name) + "\n" +
      # add a hidden the preset form field
      hidden_field_tag('id', recipient_name, :id => 'recipient_name')
    end
  end

  def recipient_name_text_field_tag(recipient_name = nil)
    default_value =  recipient_name.blank? ? I18n.t(:message_recipient_name_input_caption) : recipient_name
    text_field_tag('id', params[:id], :id => 'recipient_name', :class => 'textinput',
                                        :value => default_value,
                                        :onkeypress => eat_enter,
                                        :onfocus => hide_default_value,
                                        :onblur => show_default_value)
  end

  def send_message_function(default_recipient_name = nil)
    submit_url = message_posts_path("__ID__")
    "submitNestedResourceForm('recipient_name', '#{submit_url}', #{default_recipient_name.blank?})"
  end

  def message_html_attributes(message)
    classes = %w(message)
    classes << 'unread' if message.unread_by?(current_user)
    { :id =>"message_#{message.id}", :class => classes.join(" ") }
  end

  def message_reply_html_attributes(message)
    if message.posts_count > 1 && message.replied_by == current_user
      {:class => 'reply'}
    else
      {}
    end
  end

  def message_post_summary_body(post)
    caption = if (post.created_by == current_user)
      I18n.t(:message_you_wrote_caption)
    else
      I18n.t(:message_user_wrote_caption, :user => post.created_by.try.display_name)
    end

    # remove surrounding <p> from body_html
    html = post.body_html.try.gsub(/(\A\s*<p>)|(<\/p>\s*\Z)/, "")
    content_tag(:em, caption, :class => "message-author-caption") + " \n" +
    content_tag(:span, truncate(strip_links(html), :length => 300), :class => "message-body")
  end

  def action_bar_settings
    { :select =>
            [ {:name => :all,
               :translation => :select_all,
               :function => checkboxes_subset_function("tr.message .message_check_box", "tr.message .message_check_box")},
              {:name => :none,
                :translation => :select_none,
                :function => checkboxes_subset_function("tr.message .message_check_box", "")},
              {:name => :unread,
               :translation => :select_unread,
               :function => checkboxes_subset_function("tr.message .message_check_box", "tr.message.unread .message_check_box")}],
      :mark =>
            [ {:name => :read, :translation => :read},
              {:name => :unread, :translation => :unread}],
      :view =>
            [ {:name => :all, :translation => :messages_select_all_link},
              {:name => :unread, :translation => :messages_select_unread_link}],
      :view_base_path => messages_path }
  end

  def message_thread_actions
    { :link =>
      [ { :translation => :messages_back_to_all,
          :target => messages_path }]
    }
  end
end
