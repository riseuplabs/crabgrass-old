module Tool::RateManyHelper
  @@map = {
     2 => 'good', 'good' =>  2,
     1 => 'ok'  , 'ok'   =>  1,
     0 => 'none', 'none' =>  0,
    -1 => 'bad' , 'bad'  => -1,
    -2 => 'no'  , 'no'   => -2,
  }
  def map(value)
    @@map[value]
  end
  
  
  # value a string, one of 'good', 'ok', 'bad', 'no'
  def button_row(possible, vote, value)
    voters_list = @allvotes[value].to_sentence if @allvotes[value]
    button = radio_button_tag(
      "vote[#{possible.id}]",   # name
      map(value),               # value
      value == map(vote.value), # checked?
       :onclick => remote_function(
         :url => page_xurl(@page,:action => 'vote_one', :id => possible.id, :value => map(value)),
         :loading => show_spinner("possible_%s" % possible.id)
       )
    )
    %Q+
    <tr>
      <td><label>#{button}#{value.t}</label></td>
      <td><span>&mdash;</span> #{voters_list}</td>
    </tr>
    +
  end
end
