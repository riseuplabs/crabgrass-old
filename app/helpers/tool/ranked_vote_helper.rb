module Tool::RankedVoteHelper

 def possible_name(possible)
   if possible.description.any?
     link_to_function(possible.name,
       "Element.toggle('#{details_id(possible)}')",
       :class => 'dotted')
   else
     h(possible.name)
   end
 end

 def details_id(possible)
   possible_id = "possible_#{possible.id}"
   "#{possible_id}_details" 
 end
 
end


