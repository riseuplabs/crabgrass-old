require File.dirname(__FILE__) + '/../../test_helper'

module Wiki::RenderingTest
  def self.included(base)
    base.instance_eval do
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

      context "A saved Wiki" do
        setup do
          @wiki = Wiki.create! :body => "a"
        end

        should "have saved the correct body_html" do
          assert_equal "<p>a</p>", Wiki.find(@wiki.id).read_attribute(:body_html)
        end

        should "have saved the correct raw_structure" do
          assert_equal  WikiTest.raw_structure_for_n_byte_body(1), Wiki.find(@wiki.id).read_attribute(:raw_structure)
        end

        context "after updating the body without saving" do
          setup { @wiki.body = "bb" }

          should "have the correct body_html" do
            assert_equal "<p>bb</p>", @wiki.body_html
          end

          should "have the correct raw_structure" do
            assert_equal  WikiTest.raw_structure_for_n_byte_body(2), @wiki.raw_structure
          end

          should "not get saved when reading body_html" do
            @wiki.body_html

            assert_equal "a", Wiki.find(@wiki.id).read_attribute(:body)
            assert_equal "<p>a</p>", Wiki.find(@wiki.id).read_attribute(:body_html)
          end

          should "not get saved when reading raw_structure" do
            @wiki.raw_structure

            assert_equal "a", Wiki.find(@wiki.id).read_attribute(:body)
            assert_equal WikiTest.raw_structure_for_n_byte_body(1), Wiki.find(@wiki.id).read_attribute(:raw_structure)
          end
        end
      end

      context "A Wiki with 1 version and with a saved body" do
        setup do
          @wiki = Wiki.create!
          @wiki.update_document!(users(:blue), 1, "pickle")
        end

        should "render html for that body" do
          assert_equal "<p>pickle</p>", @wiki.body_html
        end

        should "render raw_structure for that body" do
          assert_equal WikiTest.raw_structure_for_n_byte_body(6), @wiki.raw_structure
        end

        context "after clearing body_html and raw_structure and saving" do
          setup do
            @wiki.body_html = ''
            @wiki.raw_structure = nil
            @wiki.save!
          end

          should "save regenerated body_html" do
            assert_equal "<p>pickle</p>", Wiki.find(@wiki.id).read_attribute(:body_html)
            assert_equal "<p>pickle</p>", Wiki.find(@wiki.id).versions.last.read_attribute(:body_html)
          end

          should "save regenerated raw_structure" do
            assert_equal WikiTest.raw_structure_for_n_byte_body(6), Wiki.find(@wiki.id).read_attribute(:raw_structure)
            assert_equal WikiTest.raw_structure_for_n_byte_body(6), Wiki.find(@wiki.id).versions.last.read_attribute(:raw_structure)
          end

          should "regenerate body html" do
            assert_equal "<p>pickle</p>", @wiki.body_html
          end

          should "regenerate raw_structure" do
            assert_equal WikiTest.raw_structure_for_n_byte_body(6), @wiki.raw_structure
          end

        end

        context "after clearing body_html with SQL and reloading" do
          setup do
            Wiki.update_all("body_html = ''", {:id => @wiki.id})
            @wiki.reload
          end

          should "regenerate body html" do
            assert_equal "<p>pickle</p>", @wiki.body_html
          end

          should "not have saved regenerated body html" do
            assert_equal "", Wiki.find(@wiki.id).read_attribute(:body_html)
          end

        end
      end
    end
  end

end

