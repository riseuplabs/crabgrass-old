# Due to a bug ChatChannelsUsers and ChatMessages without a channel_id were created.
# This tasks deletes them.
namespace :cg do
  namespace :chat do
    desc "Deletes ChatChannelsUsers and ChatMessages without a channel_id"
    task(:clean_invalid => :environment) do
      ChatChannelsUser.all(:conditions => "channel_id IS NULL").each do |c_user|
        c_user.destroy
      end
      ChatMessage.all(:conditions => "channel_id IS NULL").each do |m|
        m.destroy
      end
    end
  end
end

