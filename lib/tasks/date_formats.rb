desc "Show the date/time format strings defined and example output"
task :date_formats => :environment do
  now = Time.now
  [:to_date, :to_datetime, :to_time].each do |conv_meth|
    obj = now.send(conv_meth)
    puts obj.class.name
    puts "=" * obj.class.name.length
    name_and_fmts = obj.class::DATE_FORMATS.map { |k, v| [k, %Q('#{String === v ? v : '&proc'}')] }
    max_name_size = name_and_fmts.map { |k, _| k.to_s.length }.max + 2
    max_fmt_size = name_and_fmts.map { |_, v| v.length }.max + 1
    name_and_fmts.each do |format_name, format_str|
      puts sprintf("%#{max_name_size}s:%-#{max_fmt_size}s %s", format_name, format_str, obj.to_s(format_name))
    end
    puts
  end
end