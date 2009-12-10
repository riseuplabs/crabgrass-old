#
# generates visual displays of current_user's social information
#

# requires:
# apt-get install graphviz
#

require 'graphviz'


class Me::InfovizController < Me::BaseController

  def visualize
    format = params[:format] || 'svg'

    @pages = Page.find_by_path(params[:path], options_for_me)
    @activities = Activity.for_dashboard(current_user).only_visible_groups.newest.unique.find(:all, :limit => 12)

    g = GraphViz::new( "structs", :output => "svg" )
    g[:rankdir] = "LR"

    # set global node options
    #g.node[:color]    = "#ddaa66"
    g.node[:style]    = "filled"
    g.node["shape"] = "rect"
    #g.node[:shape]    = "box"
    #g.node[:penwidth] = "1"
    g.node[:fontname] = "Trebuchet MS"
    g.node[:fontsize] = "12"
    #g.node[:fillcolor]= "#ffeecc"
    #g.node[:fontcolor]= "#775500"
    #g.node[:margin]   = "0.0"

    # set global edge options
    g.edge[:dir] = "none"
    g.edge[:color]    = "#999999"
    g.edge[:weight]   = "1"
    g.edge[:fontsize] = "6"
    #g.edge[:fontcolor]= "#444444"
    #g.edge[:fontname] = "Verdana"
    #g.edge[:dir]      = "forward"
    #g.edge[:arrowsize]= "0.5"




    # add cluster for users
    uc = g.add_graph('users')
    uc.add_node('USERS', :label => 'users', :shape => 'diamond', :href => '/people')

    # add node for self
    @user = current_user
    uc.add_node @user.id.to_s,
      :label => @user.login, :href => url_for_user(@user),
      :tooltip => @user.display_name, :shape => "ellipse"
    uc.add_edge 'USERS', @user.id.to_s, :weight => "2", :color => 'blue'

    # add nodes for all contacts
    @contacts = @user.contacts

    @contacts.each do |c|
      uc.add_node c.id.to_s,
        :label => c.login, :href => url_for_user(c),
        :tooltip => 'Last seen: ' + c.last_seen_at.to_s,
        :shape => "ellipse"
      uc.add_edge 'USERS', c.id.to_s, :weight => "2", :color => 'blue'
    end

    # add edges from self to all contacts
    @contacts.each do |c|
      uc.add_edge @user.id.to_s, c.id.to_s
    end

    # add edges between all contacts
    @contacts.each do |c|
      c.contact_ids.each do |id|
        if c.id < id # and @user.contact_ids.include? id
          uc.add_edge c.id.to_s, id.to_s
        end
      end
    end


    # add cluster for groups
    gc = g.add_graph('groups')
    gc.add_node 'GROUPS', :label => 'groups', :href => '/groups', :shape => 'diamond', :color => 'red'

    # add nodes for all member groups
    @groups = @user.all_groups

    @groups.each do |gr|
      gc.add_node 'group_%d' / gr.id, :label => gr.display_name,
        :color => 'red', :shape => 'rect', :href => url_for_group(gr)
      gc.add_edge 'GROUPS', 'group_%d' / gr.id, :color => 'blue'

      # add edges to all committees
      gr.committees.each do |c|
        gc.add_edge 'group_%d' / gr.id, 'group_%d' / c.id, :weight => "200",
          :color => '#880000', :style => "dashed"
      end

      # add edges to all networks
      gr.networks.each do |n|
        gc.add_edge 'group_%d' / n.id, 'group_%d' / gr.id, :weight => "100",
          :color => '#AA4444', :style => "dashed"
      end
    end

    # add edges between @user and all member groups
    @user.group_ids.each do |id|
      g.add_edge @user.id.to_s, 'group_%d' / id
    end

    # add edges between all contacts and all member groups
    @contacts.each do |c|
      c.groups.each do |gr|
        if @groups.include? gr
          g.add_edge c.id.to_s, 'group_%d' / gr.id
        end
      end
    end


    # :use can be %w(dot neato twopi circo fdp)
    out_str = g.output(:use => 'fdp', :output => format)

    send_data(out_str,
              :type => Media::MimeType.mime_type_from_extension(format),
              :disposition => 'inline')

  end

  protected

  # no partials
  def load_partials
  end

  def context
    no_context
  end


end



