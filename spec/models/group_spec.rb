require File.dirname(__FILE__) + '/../spec_helper'

describe Group do
  before do
    @group = Group.new :name => 'banditos_for_bush'
  end

  it "should have the same tags as its pages" do
    @page = create_valid_page
    @group.save!
    @group.pages << @page
    @group.save!
    @page.tag_with 'crackers ninjas'
    @page.save!
    @group.tags.should include('ninjas')
  end

end

