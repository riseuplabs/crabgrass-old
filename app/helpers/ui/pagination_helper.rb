module UI::PaginationHelper

  protected

#  def letter_pagination_labels
#    $letter_pagination_labels_list ||= ("A".."Z").to_a + ["#"]
#  end

#  def letter_pagination_links(url_opts = {}, pagination_opts = {}, &url_proc)
#    url_proc = method :url_for if url_proc.nil?
#    available_letters = pagination_opts[:available_letters]
#    if available_letters and !available_letters.grep(/^[^a-z]/i).empty?
#      # we have things that are not letters in the mix
#      available_letters << "#"
#    end

#    render  :partial => 'pages/letter_pagination',
#                        :locals => {:letter_labels => letter_pagination_labels,
#                                    :available_letters => pagination_opts[:available_letters],
#                                    :url_proc => url_proc,
#                                    :url_opts => url_opts,
#                                    }
#  end

  #
  # Default pagination link options:
  #
  #   :class        => 'pagination',
  #   :previous_label   => '&laquo; Previous',
  #   :next_label   => 'Next &raquo;',
  #   :inner_window => 4, # links around the current page
  #   :outer_window => 1, # links around beginning and end
  #   :separator    => ' ',
  #   :param_name   => :page,
  #   :params       => nil,
  #   :renderer     => 'WillPaginate::LinkRenderer',
  #   :page_links   => true,
  #   :container    => true
  #
  def pagination_links(things, options={})
    return if !things.is_a?(WillPaginate::Collection)
    if request.xhr?
      defaults = {:renderer => LinkRenderer::Ajax, :previous_label => I18n.t(:pagination_previous), :next_label => I18n.t(:pagination_next), :inner_window => 2}
    else
      defaults = {:renderer => LinkRenderer::Dispatch, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
    end
    will_paginate(things, defaults.merge(options))
  end

  # *NEWUI
  #
  # WTF! this is an exact copy of pagination_links()!
  # i am commenting it out.
  #
  # Default pagination link options:
  #
  #   :class        => 'pagination',
  #   :previous_label   => '&laquo; Previous',
  #   :next_label   => 'Next &raquo;',
  #   :inner_window => 4, # links around the current page
  #   :outer_window => 1, # links around beginning and end
  #   :separator    => ' ',
  #   :param_name   => :page,
  #   :params       => nil,
  #   :renderer     => 'WillPaginate::LinkRenderer',
  #   :page_links   => true,
  #   :container    => true
  #
#  def pagination_for(things, options={})
#    return if !things.is_a?(WillPaginate::Collection)
#    if request.xhr?
#      defaults = {:renderer => LinkRenderer::Ajax, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
#    else
#      defaults = {:renderer => LinkRenderer::Dispatch, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
#    end
#    will_paginate(things, defaults.merge(options))
#  end


end

