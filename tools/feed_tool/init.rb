
self.load_once = false

require '/home/suung/workspace/crabgrass/tools/feed_tool/lib/participation.rb'
require '/home/suung/workspace/crabgrass/tools/feed_tool/lib/subscribable.rb'


UserParticipation.send(:include, Feedr::Participation)
GroupParticipation.extend Feedr::Participation
