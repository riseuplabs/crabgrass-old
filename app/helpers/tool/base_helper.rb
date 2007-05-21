module Tool::BaseHelper

  def header_for_page_create(page_class)
    %Q[
    <div class='page-class'>
      <span class='page-link' style='background: url(/images/pages/big/#{page_class.icon}) no-repeat 0% 50%'><b>#{page_class.class_display_name.t}</b>: #{page_class.class_description.t}</span>
    </div>
    ]
  end

end
