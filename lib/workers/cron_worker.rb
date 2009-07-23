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

  # updates page.views_count and hourlies from the data in the trackings table.
  # this should be called frequently.
  def process_trackings
    Tracking.process
  end

  # updates dailies from the data in the hourlies table.
  # this should be called once per day.
  def update_dailies
    Daily.update
  end

  # updates the last_seen field of the users table.
  # this should be called every other minute.
  def update_last_seen
    Tracking.update_last_seen
  end

  # the output of this is logged to: log/backgroundrb_debug_11006.log
  # if debug_log == true in backgroundrb.yml
  def reindex_sphinx
    system('rake', '--rakefile', RAILS_ROOT+'/Rakefile', 'ts:index', 'RAILS_ENV=production')
  end

  def clean_codes
    Code.cleanup_expired
  end

end

