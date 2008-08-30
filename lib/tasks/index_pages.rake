=begin

For thinking_sphinx / sphinxsearch to index pages in crabgrass, we need to have
a page_index table with an entry for each page.  This rake task makes sure that
each page has an up-to-date page_index.

=end

namespace :cg do
  desc "update page_index for each page."
  
  task :update_page_index => :environment do
    val = ThinkingSphinx.deltas_enabled?
    ThinkingSphinx.deltas_enabled = false

    Page.all.each { |page| puts page.id; page.update_index }

    ThinkingSphinx.deltas_enabled = val
  end
end
