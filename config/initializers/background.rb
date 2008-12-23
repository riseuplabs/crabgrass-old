
#
# returns true if backgrounDRb daemon is running
#
def backgroundrb_running?
  defined?(MiddleMan) and MiddleMan.all_worker_info.to_a.first[1].any?
end

