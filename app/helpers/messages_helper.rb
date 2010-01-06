module MessagesHelper
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

  # target is :all, :none or :unread
  def select_messages_function(target)
    selectors = {
      :all => "tr.message .message_check_box",
      :unread => "tr.message.unread .message_check_box",
      :none => ''
    }

    uncheck_selector = selectors[:all]
    check_selector = selectors[target]

    # first, unselect all checkboxes
    # then, select target subset of checkboxes
    "toggleAllCheckboxes(false, '#{uncheck_selector}'); toggleAllCheckboxes(true, '#{check_selector}')"
  end

  # as is either :read or :unread
  def mark_selected_messages(as)
    "$('mark_messages_as').value = '#{as}';this.up('form#mark_messages_form').onsubmit()"
  end

  def view_filter_select
    options = options_for_select({I18n.t(:messages_select_all_link) => 'all',
                                  I18n.t(:messages_select_unread_link) => 'unread'}, params[:view])
    select_tag 'view_filter_select', options
  end
end