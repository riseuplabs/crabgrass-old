class GroupProfilesMakeApprovalMembershipPolicyDefault < ActiveRecord::Migration
  def self.up
    change_column :profiles, :membership_policy, :integer, :default => Profile::MEMBERSHIP_POLICY[:approval]
    Profile.update_all("membership_policy = #{Profile::MEMBERSHIP_POLICY[:approval]}")
  end

  def self.down
    change_column :profiles, :membership_policy, :integer
    Profile.update_all("membership_policy = NULL")
  end
end
