class Admin::MembershipsController < Admin::BaseController
  before_filter :find_membership, :except => :create
  before_filter :find_group_and_user, :only => :create

  permissions 'admin/super'

  def create
    if @group and @user
      @group.add_user!(@user)
    else
      flash[:notice] = 'no such user or group'
    end
    redirect_to edit_group_path(@group)
  end

  def destroy
    @membership.group.remove_user!(@membership.user)
    redirect_to edit_group_path(@group)
  end

  private

  def find_group_and_user
    @group = Group.find(params[:group_id])
    @user = User.find_by_login(params[:user_login])
  end

  def find_membership
    @membership = Membership.find(params[:id])
    @group = @membership.group
#  rescue ActiveRecord::RecordNotFound
#    render_404
  end
end

