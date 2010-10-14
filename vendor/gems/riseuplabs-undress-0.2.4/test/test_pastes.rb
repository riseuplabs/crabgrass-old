require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class Undress::PasteToGreenclothTest < Undress::GreenClothTest


  context "parsing Office pastes" do
    context "with all the tag soup" do
      test "a simple numbered list" do
        html = <<eoh
<p><meta name="Originator" content="Microsoft Word 10"><!--[if gte mso 9]><xml><br />  <w:WordDocument><br />  <w:View>Normal</w:View><br />  <w:Zoom>0</w:Zoom><br />  <w:HyphenationZone>21</w:HyphenationZone><br />  <w:Compatibility><br />  <w:BreakWrappedTables/><br />  <w:SnapToGridInCell/><br />  <w:WrapTextWithPunct/><br />  <w:UseAsianBreakRules/><br />  </w:Compatibility><br />  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel><br />  </w:WordDocument><br /> </xml><![endif]--><style><br /> <!--<br />  /* Style Definitions */<br />  p.MsoNormal, li.MsoNormal, div.MsoNormal<br />  {mso-style-parent:"";<br />  margin:0cm;<br />  margin-bottom:.0001pt;<br />  mso-pagination:widow-orphan;<br />  font-size:12.0pt;<br />  font-family:"Times New Roman";<br />  mso-fareast-font-family:"Times New Roman";}<br /> @page Section1<br />  {size:612.0pt 792.0pt;<br />  margin:70.85pt 70.85pt 2.0cm 70.85pt;<br />  mso-header-margin:36.0pt;<br />  mso-footer-margin:36.0pt;<br />  mso-paper-source:0;}<br /> div.Section1<br />  {page:Section1;}<br />  /* List Definitions */<br />  @list l0<br />  {mso-list-id:725950568;<br />  mso-list-type:hybrid;<br />  mso-list-template-ids:-300763278 67567631 -1247399312 67567643 67567631 67567641 67567643 67567631 67567641 67567643;}<br /> @list l0:level2<br />  {mso-level-start-at:0;<br />  mso-level-number-format:bullet;<br />  mso-level-text:-;<br />  mso-level-tab-stop:72.0pt;<br />  mso-level-number-position:left;<br />  text-indent:-18.0pt;<br />  font-family:"Times New Roman";<br />  mso-fareast-font-family:"Times New Roman";}<br /> ol<br />  {margin-bottom:0cm;}<br /> ul<br />  {margin-bottom:0cm;}<br /> --><br /> </style><!--[if gte mso 10]><br /> <style><br />  /* Style Definitions */<br />  table.MsoNormalTable<br />  {mso-style-name:"Normale Tabelle";<br />  mso-tstyle-rowband-size:0;<br />  mso-tstyle-colband-size:0;<br />  mso-style-noshow:yes;<br />  mso-style-parent:"";<br />  mso-padding-alt:0cm 5.4pt 0cm 5.4pt;<br />  mso-para-margin:0cm;<br />  mso-para-margin-bottom:.0001pt;<br />  mso-pagination:widow-orphan;<br />  font-size:10.0pt;<br />  font-family:"Times New Roman";}<br /> </style><br /> <![endif]--></p> <ol style="margin-top: 0cm;" start="1" type="1"><li class="MsoNormal" style="">asdf</li><li class="MsoNormal" style="">qwer</li><li class="MsoNormal" style="">yxcv</li></ol>
eoh
        greencloth = "# asdf\n# qwer\n# yxcv\n"
        assert_renders_greencloth greencloth, html
      end

      test "heading and a numbered list" do
        html = <<eoh
<p><meta name="ProgId" content="Word.Document"><meta name="Originator" content="Microsoft Word 10"><!--[if gte mso 9]><xml><br />  <w:WordDocument><br />  <w:View>Normal</w:View><br />  <w:Zoom>0</w:Zoom><br />  <w:HyphenationZone>21</w:HyphenationZone><br />  <w:Compatibility><br />  <w:BreakWrappedTables/><br />  <w:SnapToGridInCell/><br />  <w:WrapTextWithPunct/><br />  <w:UseAsianBreakRules/><br />  </w:Compatibility><br />  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel><br />  </w:WordDocument><br /> </xml><![endif]--><style><br /> <!--<br />  /* Style Definitions */<br />  p.MsoNormal, li.MsoNormal, div.MsoNormal<br />  {mso-style-parent:"";<br />  margin:0cm;<br />  margin-bottom:.0001pt;<br />  mso-pagination:widow-orphan;<br />  font-size:12.0pt;<br />  font-family:"Times New Roman";<br />  mso-fareast-font-family:"Times New Roman";}<br /> h2<br />  {mso-style-next:Standard;<br />  margin-top:12.0pt;<br />  margin-right:0cm;<br />  margin-bottom:3.0pt;<br />  margin-left:0cm;<br />  mso-pagination:widow-orphan;<br />  page-break-after:avoid;<br />  mso-outline-level:2;<br />  font-size:14.0pt;<br />  font-family:Arial;<br />  font-style:italic;}<br /> @page Section1<br />  {size:612.0pt 792.0pt;<br />  margin:70.85pt 70.85pt 2.0cm 70.85pt;<br />  mso-header-margin:36.0pt;<br />  mso-footer-margin:36.0pt;<br />  mso-paper-source:0;}<br /> div.Section1<br />  {page:Section1;}<br />  /* List Definitions */<br />  @list l0<br />  {mso-list-id:725950568;<br />  mso-list-type:hybrid;<br />  mso-list-template-ids:-300763278 67567631 -1247399312 67567643 67567631 67567641 67567643 67567631 67567641 67567643;}<br /> @list l0:level2<br />  {mso-level-start-at:0;<br />  mso-level-number-format:bullet;<br />  mso-level-text:-;<br />  mso-level-tab-stop:72.0pt;<br />  mso-level-number-position:left;<br />  text-indent:-18.0pt;<br />  font-family:"Times New Roman";<br />  mso-fareast-font-family:"Times New Roman";}<br /> ol<br />  {margin-bottom:0cm;}<br /> ul<br />  {margin-bottom:0cm;}<br /> --><br /> </style><!--[if gte mso 10]><br /> <style><br />  /* Style Definitions */<br />  table.MsoNormalTable<br />  {mso-style-name:"Normale Tabelle";<br />  mso-tstyle-rowband-size:0;<br />  mso-tstyle-colband-size:0;<br />  mso-style-noshow:yes;<br />  mso-style-parent:"";<br />  mso-padding-alt:0cm 5.4pt 0cm 5.4pt;<br />  mso-para-margin:0cm;<br />  mso-para-margin-bottom:.0001pt;<br />  mso-pagination:widow-orphan;<br />  font-size:10.0pt;<br />  font-family:"Times New Roman";}<br /> </style><br /> <![endif]--></p> <h2>qweqwer</h2> <p class="MsoNormal"><o:p>&nbsp;</o:p></p> <ol style="margin-top: 0cm;" start="1" type="1"><li class="MsoNormal" style="">asdf</li><li class="MsoNormal" style="">qwer</li><li class="MsoNormal" style="">yxcv</li></ol>
eoh
        greencloth = "qweqwer\n-------\n\n# asdf\n# qwer\n# yxcv\n"
        assert_renders_greencloth greencloth, html
      end
    end

    context "with particular issues" do
      test "heading and then numbered list" do
        html = <<eoh
<h2>qweqwer</h2> <p class="MsoNormal"><o:p>&nbsp;</o:p></p> <ol style="margin-top: 0cm;" start="1" type="1"><li class="MsoNormal" style="">asdf</li><li class="MsoNormal" style="">qwer</li><li class="MsoNormal" style="">yxcv</li></ol>
eoh
        greencloth = "qweqwer\n-------\n\n# asdf\n# qwer\n# yxcv\n"
        assert_renders_greencloth greencloth, html
      end

      test "with whitespace at the end of tags" do
        html = "<strong>no space here: </strong>"
        greencloth = "*no space here:* "
        assert_renders_greencloth greencloth, html
      end
    end
  end
end
