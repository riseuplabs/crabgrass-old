require File.dirname(__FILE__) + '/../../../../test/test_helper'

class WikiPageTest < ActiveSupport::TestCase
  fixtures :users

  context "Two WikiPages with the same title added to the same group" do
    setup do
      @wiki1 = WikiPage.create :title => 'x61'
      @wiki2 = WikiPage.create :title => 'x61'

      g = Group.create! :name => 'robots'

      @wiki1.add g; @wiki1.save
      @wiki2.add g; @wiki2.save
    end

    should "get the name set to title for the first" do
      assert_equal 'x61', @wiki1.name
    end

    should "see that name is taken for the second" do
      assert @wiki2.name_taken?
    end

    should "not be valid for the second" do
      assert !@wiki2.valid?
    end
  end

  context "Two WikiPages with the same title created for the same user" do
    setup do
      @wiki1 = WikiPage.create :title => 'x61', :owner => 'blue', :user => users(:blue)
      @wiki2 = WikiPage.create :title => 'x61', :owner => 'blue', :user => users(:blue)
    end

    should "get the name set to title for the first" do
      assert_equal 'x61', @wiki1.name
    end

    should "see that name is taken for the second" do
      assert @wiki2.name_taken?
    end

    should "not be valid for the second" do
      assert !@wiki2.valid?
    end
  end
end
