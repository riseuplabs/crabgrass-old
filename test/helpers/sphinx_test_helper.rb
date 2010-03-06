module SphinxTestHelper
  def print_sphinx_hints
    @@sphinx_hints_printed ||= false
    unless @@sphinx_hints_printed
    # cg:update_page_terms
      puts "\nTo make thinking_sphinx tests not skip, try the following steps:
  rake RAILS_ENV=test db:test:prepare db:fixtures:load  # (should not be necessary, but always a good first step)
  rake RAILS_ENV=test ts:index ts:start                 # (needed to build the sphinx index and start searchd)
  rake test:functionals
See also doc/SPHINX"
      @@sphinx_hints_printed = true
    end

  end

  def sphinx_working?(test_name="")
    if !ThinkingSphinx.sphinx_running?
      print 'skip'
      print_sphinx_hints
      false
    else
      true
    end
  end
end