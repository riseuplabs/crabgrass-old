class CronWorker < BackgrounDRb::MetaWorker
  set_worker_name :cron_worker

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def clean_fragment_cache(arg)
    # remove all files that have had their status changed more than three days ago.
    system("find", RAILS_ROOT+'/tmp/cache', '-ctime', '+3', '-exec', 'rm', '{}', ';')
    # (on a system with user accounts, tmpreaper should be used instead.)
  end

  def clean_session_cache(arg)
    # remove all files that have had their status changed more than three days ago.
    system("find", RAILS_ROOT+'/tmp/sessions', '-ctime', '+3', '-exec', 'rm', '{}', ';')
    # (on a system with user accounts, tmpreaper should be used instead.)
  end

  # updates page.views_count from the data in the page_views table.
  # this should be called frequently.
  def update_page_views_count(arg)
    PageView.update_page_views_count
  end

  def reindex_sphinx(arg)
    system('rake', '--rakefile', RAILS_ROOT+'/Rakefile', 'ts:index', 'RAILS_ENV=production')
  end

end

