require File.dirname(__FILE__) + '/../../spec_helper'
describe Tool::BaseController do
  describe "when creating a new page" do
    TOOLS.each do |tool|
      it "should instantiate #{tool} from params[:id] == '#{tool.class_display_name}'" do
        controller.stub!(:get_groups).and_return([])
        controller.stub!(:get_users).and_return([])
        controller.stub!(:params).and_return({:id => tool.class_display_name, :page => {}})
        controller.stub!(:current_user).and_return(User.new(:id => 1))
        page = controller.create_new_page
        page.should be_a_kind_of(tool)
      end if tool.class_display_name
    end

    describe "when passed invalid options" do
      it "should return an invalid page" do
        controller.stub!(:get_groups).and_return([])
        controller.stub!(:get_users).and_return([])
        controller.stub!(:params).and_return({:id => 'wiki', :page => {}}) #no title, not valid
        controller.stub!(:current_user).and_return(User.new(:id => 1))
        page = controller.create_new_page
        page.should_not be_valid
      end
    end
  end
end


