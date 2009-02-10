#
# this is taken from acts_as_taggable_on_steriods
#
# View:
#
#  <% tag_cloud @tags, %w(tag1 tag2 tag3 tag4) do |tag, css_class| %>
#    <%= link_to tag.name, { :action => :tag, :id => tag.name }, :class => css_class %>
#  <% end %>
#  
# CSS:
#
#  .tag1 { font-size: 1.0em; }
#  .tag2 { font-size: 1.2em; }
#  .tag3 { font-size: 1.4em; }
#  .tag4 { font-size: 1.6em; }
#
module TagsHelper
  def tag_cloud(tags, classes, max_list=false)
    return if tags.empty?
    
    max_count = tags.sort_by(&:count).last.count.to_f
    max_list_count = tags.sort_by(&:count)[0-max_list].count if max_list
    
    tag_count = 0
    debugger
    tags.each do |tag|
      next if max_list and (tag.count < max_list_count || (tag.count == max_list_count && tag_count >= max_list))
      tag_count += 1
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end
end
