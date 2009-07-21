module StatsHelper

  # data = [
  #  {:label = 'tree', :data => [[1,1],[2,3],[5,7]]},
  #  {:label => 'birds', :data => [[1,1],[2,3],[5,7]]}
  # ]
  def time_series_chart(*datas)
    id = "chart%s" % rand(Time.now)

    html = document_observe( chart_function(id, datas) )
    join([
      content_tag(:div, '', :style=>"width:700px;height:300px;", :id => id),
      javascript_tag( html )
    ])
  end

  def document_observe(content) 
    "document.observe('dom:loaded', function(){\n%s\n});" % content
  end

  def join(array)
    array.join("\n")
  end

  def chart_function(id, datas)
    chart_def = ['[']
    datas.each do |data, i| 
      chart_def << "{data:%s, label:'%s', lines:{fill: true}}, " % [data[:data].to_json, data[:label]]
    end
    chart_def << '],'
    chart_def << "{mouse:{track: true}, xaxis:{noTicks: 7, tickFormatter: function(n){ var t = new Date(); t.setTime(n*1000); return t.toLocaleDateString();}}}"

    "Flotr.draw($('%s'), %s);" % [id, chart_def.join("\n")]
  end

  def section(title)
    @toc ||= []
    @toc << {:title => title, :name => title.nameize, :children => []}
    content_tag(:h1, content_tag(:a, title, :name => title.nameize))
  end

  def subsection(title)
    @toc.last[:children] << {:title => title, :name => title.nameize}
    content_tag(:h2, content_tag(:a, title, :name => title.nameize))
  end
end

