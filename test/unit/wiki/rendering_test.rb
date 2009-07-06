require File.dirname(__FILE__) + '/../../test_helper'

class Wiki::RenderingTest < Test::Unit::TestCase
  fixtures :users, :wikis

  context "A new Wiki" do
     setup {@wiki = Wiki.new :body => "a"}

     should "have the correct body_html" do
       assert_equal "<p>a</p>",  @wiki.body_html
     end

     should "not get saved when reading body_html" do
       @wiki.body_html
       assert @wiki.new_record?
     end
   end
   
   context "A versioned Wiki with saved body" do
     setup do
       @wiki = Wiki.create!
       @wiki.update_document!(users(:blue), 1, "pickle")
     end

     should "render html for that body" do
       assert_equal "<p>pickle</p>", @wiki.body_html
     end

     context "after clearing body_html and saving" do
       setup do
         @wiki.body_html = ''
         @wiki.save!
       end

       should "regenerate body html" do
         assert_equal "<p>pickle</p>", @wiki.body_html
         assert_equal "<p>pickle</p>", @wiki.versions.last.body_html
       end
     end

     context "after clearing body_html with SQL and reloading" do
       setup do
         Wiki.update_all("body_html = ''", {:id => @wiki.id})
         @wiki.reload
       end

       should "regenerate body html" do
         assert_equal "<p>pickle</p>", @wiki.body_html
         assert_equal "<p>pickle</p>", @wiki.versions.last.body_html
       end
     end
   end

   context "A saved Wiki" do
     setup do
       @wiki = Wiki.create! :body => "a"
     end

     should "have saved the correct body_html" do
       reloaded = @wiki.reload
       assert_equal "<p>a</p>", reloaded.read_attribute(:body_html)
     end

     should "have saved the correct raw_structure" do
       reloaded = @wiki.reload
       assert reloaded.read_attribute(:raw_structure).has_key?(:document)
     end

    context "after updating the body without saving" do
      setup { @wiki.body = "b" }

      context "and reading body_html" do
        setup { @body_html = @wiki.body_html }

        should "have the correct body_html" do
          assert_equal "<p>b</p>", @body_html
        end

        should "save body_html" do
          assert_equal "<p>b</p>", Wiki.find(@wiki.id).read_attribute(:body_html)
        end
      end
    end
  end
end