module StatsHelper

  # data = [
  #  {:label = 'tree', :data => [[1,1],[2,3],[5,7]]},
  #  {:label => 'birds', :data => [[1,1],[2,3],[5,7]]}
  # ]
  def time_series_chart(*datas)
    draw_chart(
      datas,
      :xaxis => {
        :noTicks => 7,
        :tickFormatter => json_function('function(n){ var t = new Date(); t.setTime(n*1000); return t.toLocaleDateString();}')
      }
    )
  end

  def chart(*datas)
    options = datas.pop
    draw_chart(datas, options)
  end

  # makes the string get converted to json but directly without surrounding it with
  # quotation marks
  def json_function(str)
    str.instance_eval do |base|
      def to_json(*args)
        self
      end
    end
    return str
  end

  private

  def draw_chart(datas, options={})
    options = {:mouse => {:track => true}}.merge(options)
    id = "chart%s" % rand(Time.now)

    html = document_observe( chart_function(id, datas, options) )
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

  def chart_function(id, datas, options)
    chart_def = []
    datas.each do |data, i|
      chart_def << "{data:%s, label:'%s', lines:{fill: true}}, " % [data[:data].to_json, data[:label]]
    end
    "  Flotr.draw(\n    $('%s'), [\n      %s\n    ],\n    %s\n  );" % [id, chart_def.join("\n      "), options.to_json]
  end

  def section(title)
    @toc ||= []
    @toc << {:title => title, :name => title.nameize, :children => []}
    content_tag(:h1, content_tag(:a, title, :name => title.nameize))
  end

  def subsection(title)
    name = @toc.last[:name] + '-' + title.nameize
    @toc.last[:children] << {:title => title, :name => name}
    content_tag(:h2, content_tag(:a, title, :name => name))
  end
end

