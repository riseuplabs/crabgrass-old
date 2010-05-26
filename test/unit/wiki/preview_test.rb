require File.dirname(__FILE__) + '/../../test_helper'

module Wiki::PreviewTest
  def self.included(base)
    base.instance_eval do
      context "A new Wiki with typical content" do
        body = <<EOWIKI
[[toc]]

h1. first big caption here

and then some paragraph with some text to go with it...

h2. we might want another caption

| how do we | split tables? |
| what about | second row? |

h1. yet another big one.
EOWIKI

         setup {@wiki = Wiki.new :body => body}

         should "return body if < length given" do
           assert_equal @wiki.body_html,  @wiki.send(:render_preview, 1000)
         end

         should "not contain toc" do
           assert_no_match /<ul class="toc">/, @wiki.send(:render_preview, 100)
         end

         should "create valid tables" do
           assert_match /<\/table>/,  @wiki.send(:render_preview, 180)
         end
      end
    end
  end

end
