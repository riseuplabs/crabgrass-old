require File.dirname(__FILE__) + '/../test_helper'

class WikiTest < Test::Unit::TestCase
  fixtures :users, :wikis

  should "have good associations" do
    assert check_associations(Wiki)
  end

  def test_saving
    w = Wiki.create :body => 'watermelon'
    w.lock(Time.now, users(:blue))

    # version is too old
    assert_raise ErrorMessage do
      w.smart_save! :body => 'catelope', :version => -1, :user => users(:blue)
    end

    # already locked
    assert_raise ErrorMessage do
      w.smart_save! :body => 'catelope', :user => users(:red)
    end

    assert_nothing_raised do
      w.smart_save! :body => 'catelope', :user => users(:blue)
    end
  end

  context "A wiki" do
    setup {@wiki = Wiki.new }

    context "A wiki with four versions" do
      setup do
        @wiki = Wiki.create! :body => '1111'
        @wiki.smart_save!(:body => '2222', :user => users(:red))
        @wiki.smart_save!(:body => '3333', :user => users(:green))
        @wiki.smart_save!(:body => '4444', :user => users(:blue))
      end
      should_change "versions count", :from => 0, :to => 4 do @wiki.versions.size end

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
