require File.dirname(__FILE__) + '/../test_helper'

class WikiTest < Test::Unit::TestCase
  fixtures :users, :wikis

  def self.should_have_latest_body body
    should "have the latest body" do
      assert_equal body, @wiki.body
    end

    should "have the latest body for its most recent version" do
      assert_equal body, @wiki.versions.last.body
    end
  end

  def self.should_have_latest_body_html body_html
    should "have the latest body_html" do
      assert_equal body_html, @wiki.body_html
    end

    should "have the latest body_html for its most recent version" do
      assert_equal body_html, @wiki.versions.last.body_html
    end
  end

  def self.should_have_latest_raw_structure raw_structure
    should "have the latest raw_structure" do
      assert_equal raw_structure, @wiki.raw_structure
    end

    should "have the latest raw_structure for its most recent version" do
      assert_equal raw_structure, @wiki.versions.last.raw_structure
    end
  end

  should "Wiki have good associations" do
    assert(check_associations(Wiki))
  end



  context "A new Wiki locked by an user" do
    setup do
      @wiki = Wiki.create :body => 'watermelon'
      @wiki.lock :document, users(:blue)
    end

    should "fail to save with no user set" do
      assert_raises(ActiveRecord::RecordInvalid) { @wiki.save! }
    end

    should "fail to save if version is set too old" do
      w.update_attributes! :body => 'catelope', :version => -1, :user => users(:blue)
    end

    should "fail to save when user is set to non locking user" do
      assert_raises(WikiLockException) do
        w.update_attributes! :body => 'catelope', :user => users(:red)
      end
    end

    should "save when that user is set as wiki owner" do
      assert_nothing_raised do
        w.update_attributes! :body => 'catelope', :user => users(:blue)
      end
    end

    should "save when version is set correctly" do
      assert_nothing_raised do
        w.update_attributes! :body => 'catelope', :user => users(:blue), :version => 0
      end
    end
  end


  context "A new Wiki" do
    setup {@wiki = Wiki.new }

    context "before saving" do
      should "have no versions" do
        assert @wiki.versions.empty?
      end
    end

    context "saved with a body by user 'blue'" do
      setup do
        @wiki.body = 'hi'
        @wiki.user = users(:blue)
        assert_nothing_raised { @wiki.save! }
      end

      should_change("versions count", :from => 0, :to => 1) { @wiki.versions.size }

      context "and then saved with the same body by different user" do
        setup do
          @wiki.user = users(:red)
          assert_nothing_raised { @wiki.save! }
        end

        should_not_change("versions count") { @wiki.versions.size }
        should_have_latest_body('hi')
        should_have_latest_body_html '<p>hi<p>'
      end

      context "and saved with a new body by a different user" do
        setup do
          @wiki.body = 'hi there'
          @wiki.user = users(:red)
          assert_nothing_raised { @wiki.save! }
        end

        should_change("versions count", :from => 1, :to => 2) { @wiki.versions.size }

        should_have_latest_body 'hi there'
        should_have_latest_body_html '<p>hi there<p>'
      end

      context "and saved with a new body by the same user" do
        setup do
          @wiki.body = 'hey you'
          @wiki.user = users(:blue)
          assert_nothing_raised { @wiki.save! }
        end

        should_not_change("versions count") { @wiki.versions.size }

        should_have_latest_body 'hey you'
        should_have_latest_body_html '<p>hey you<p>'
      end
    end

    context "saved with '' (empty string) body by user 'blue'" do
      setup do
        @wiki.body = ''
        @wiki.user = users(:blue)
        assert_nothing_raised { @wiki.save! }
      end

      should_change("versions count", :from => 0, :to => 1) { @wiki.versions.size }

      should_have_latest_body ''
      should_have_latest_body_html ''
      should_have_latest_raw_structure({})

      context "and then saved with new body by a different user" do
        setup do
          @wiki.body = 'oi'
          @wiki.user = users(:red)
          assert_nothing_raised { @wiki.save! }
        end

        should_not_change("versions count") { @wiki.versions.size }

        should_have_latest_body 'oi'
        should_have_latest_body_html '<p>oi</p>'

        should_have_latest_raw_structure({:document => {
          :parent => nil,
          :children => [],
          :start_index => 0,
          :end_index => 1,
          :header_end_index => 0}})
      end

    end

    context "saved with nil body by user 'blue'" do
      setup do
        @wiki.body = nil
        @wiki.user = users(:blue)
        assert_nothing_raised { @wiki.save! }
      end

      should_change("versions count", :from => 0, :to => 1) { @wiki.versions.size }

      should_have_latest_body nil
      should_have_latest_body_html ''
      should_have_latest_raw_structure({})


      context "and then saved with new body by a different user" do
        setup do
          @wiki.body = 'oi'
          @wiki.user = users(:red)
          assert_nothing_raised { @wiki.save! }
        end

        should_not_change("versions count") { @wiki.versions.size }

        should_have_latest_body 'oi'
        should_have_latest_body_html '<p>oi</p>'

        should_have_latest_raw_structure({:document => {
          :parent => nil,
          :children => [],
          :start_index => 0,
          :end_index => 1,
          :header_end_index => 0}})
      end
    end

    context "with four versions" do
      setup do
        @wiki = Wiki.create! :body => '1111', :user => users(:blue)
        @wiki.update_document!(users(:red), 1, '2222')
        @wiki.update_document!(users(:green), 2, '3333')
        @wiki.update_document!(users(:blue), 3, '4444')
      end
      should_change("versions count", :from => 0, :to => 4) { @wiki.versions.size }

      should "find version 1 body" do
        assert_equal '1111', @wiki.versions.find_by_version(1).body
      end

      should "find version 4 body" do
        assert_equal '4444', @wiki.versions.find_by_version(4).body
      end

      context "after a soft revert to an older version" do
        setup {@wiki.revert_to_version(3, users(:purple)) }

        should "create a new version equal to the older version" do
          assert_equal '3333', @wiki.versions.find_by_version(5).body
        end

        should "revert wiki body" do
          assert_equal '3333', @wiki.body
        end
      end

      context "after a hard revert to an older version" do
        setup {@wiki.revert_to_version!(2, users(:purple))}

        should "revert wiki body" do
          assert_equal '2222', @wiki.body
        end

        should "delete all newer versions" do
          assert_equal 2, @wiki.versions(true).size
        end

        should "keep the version it was reverted to" do
          assert_equal '2222', @wiki.versions.find_by_version(2).body
        end
      end
    end
  end

end
