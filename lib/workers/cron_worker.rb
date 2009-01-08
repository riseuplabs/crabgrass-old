class CronWorker < BackgrounDRb::MetaWorker
  set_worker_name :cron_worker

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def clean_fragment_cache
    # remove all files that have had their status changed more than three days ago.
    system("find", RAILS_ROOT+'/tmp/cache', '-ctime', '+3', '-exec', 'rm', '{}', ';')
    # (on a system with user accounts, tmpreaper should be used instead.)
  end

  def clean_session_cache
    # remove all files that have had their status changed more than three days ago.
    system("find", RAILS_ROOT+'/tmp/sessions', '-ctime', '+3', '-exec', 'rm', '{}', ';')
    # (on a system with user accounts, tmpreaper should be used instead.)
  end

  # updates page.views_count from the data in the page_views table.
  # this should be called frequently.
  def update_trackings
    Tracking.update_trackings
  end

  # the output of this is logged to: log/backgroundrb_debug_11006.log
  # if debug_log == true in backgroundrb.yml
  def reindex_sphinx
    system('rake', '--rakefile', RAILS_ROOT+'/Rakefile', 'ts:index', 'RAILS_ENV=production')
  end

end

