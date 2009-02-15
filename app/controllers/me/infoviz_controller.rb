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

    g = GraphViz::new( "structs", :output => "svg" )

    g.node["shape"] = "plaintext"

    g.add_node( "HTML" )

    g.add_node( "struct1", "html" => '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">  <TR><TD>left</TD><TD PORT="f1">mid dle</TD><TD PORT="f2">right</TD></TR> </TABLE>>]; struct2 [label=< <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">  <TR><TD PORT="f0">one</TD><TD>two</TD></TR> </TABLE>')

    g.add_node( "struct2", "html" => '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">  <TR><TD PORT="f0">one</TD><TD>two</TD></TR> </TABLE>' )
    g.add_node( "struct3", "html" => '<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4">  <TR>  <TD ROWSPAN="3">hello<BR/>world</TD>  <TD COLSPAN="3">b</TD>  <TD ROWSPAN="3">g</TD>  <TD ROWSPAN="3">h</TD>  </TR>  <TR>  <TD>c</TD><TD PORT="here">d</TD><TD>e</TD>  </TR>  <TR>  <TD COLSPAN="3">f</TD>  </TR> </TABLE>' )

    g.add_edge( "struct1:f1", "struct2:f0" )
    g.add_edge( "struct1:f2", "struct3:here" )

    g.add_edge( "HTML", "struct1" )

    send_data(g.output(:output => format),
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



