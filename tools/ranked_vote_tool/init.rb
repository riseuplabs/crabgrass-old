# Include hook code here

PageClassRegistrar.add(
  'RankedVotePage',
  :controller => 'ranked_vote_page',
  :model => 'Poll',
  :icon => 'page_ranked',
  :class_group => 'vote',
  :order => 11
)

#self.override_views = true
self.load_once = false

