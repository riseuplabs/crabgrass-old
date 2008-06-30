# Include hook code here

PageClassRegistrar.add(
  'RankedVotePage',
  :controller => 'ranked_vote_page',
  :model => 'Poll',
  :icon => 'ballot.png',
  :class_display_name => 'ranked vote',
  :class_description => 'Rank possibilities in order of preference.',
  :class_group => 'vote'
)

#self.override_views = true
self.load_once = false

