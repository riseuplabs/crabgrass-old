Dir.glob(File.dirname(__FILE__) + '/*.rb') do |task_file|
  require task_file
end
