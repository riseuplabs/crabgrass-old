module HtmlHelper

  def html_tab(f)
    f.tab do |t|
      t.id       "link-tab-html"
      t.selected preferred_editor_tab == :html
      t.label    wiki_editor_tab_label(:html)
      t.class    "page_url"
      if Conf.text_editor_sym == :html_preferred
        t.style  "padding-right: 1em; margin-right: 0.75em; border-right: 2px solid #ccc;"
      end
      t.function "selectWikiEditorTab('%s', %s)" % [
        page_xurl(@page, :action => 'update_editors', :editor => 'html'),
        {
          :wiki_id => @wiki.id,
          :tab_id  => 'link-tab-html',
          :area_id => 'tab-edit-html',
          :editor  => 'html',
          :token   => form_authenticity_token
        }.to_json
      ]
    end
  end
end

