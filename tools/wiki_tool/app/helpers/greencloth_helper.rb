module GreenclothHelper

  def greencloth_tab(f)
    f.tab do |t|
      t.id       "link-tab-greencloth"
      t.selected preferred_editor_tab == :greencloth
      t.label    wiki_editor_tab_label(:plain)
      if Conf.text_editor_sym == :html_preferred
        t.class  "page_url float_right"
      else
        t.class  "page_url"
      end
      t.function "selectWikiEditorTab('%s', %s)" % [
        page_xurl(@page, :action => 'update_editors', :editor => 'greencloth'),
        {
        :wiki_id => @wiki.id,
        :tab_id  => 'link-tab-greencloth',
        :area_id => 'tab-edit-greencloth',
        :editor  => 'greencloth',
        :token   => form_authenticity_token
      }.to_json
      ]
    end
  end
end

