=begin

For thinking_sphinx / sphinxsearch to index pages in crabgrass, we need to have
a page_terms table with an entry for each page.  This rake task makes sure that
each page has an up-to-date page_terms entry.

=end

namespace :cg do
  desc "update page_terms for each page."
  
  task :update_page_terms => :environment do
    val = ThinkingSphinx.deltas_enabled?
    ThinkingSphinx.deltas_enabled = false

    Page.all.each { |page| print "#{page.id} "; page.update_page_terms; STDOUT.flush; }

    ThinkingSphinx.deltas_enabled = val
    puts "done"
  end
end
