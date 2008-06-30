class ConvertToolsToPagePlugins < ActiveRecord::Migration
  def self.up
    changes = {
      'Tool::Discussion'        => 'DiscussionPage',
      'Tool::RateMany'          => 'RateManyPage',
      'Tool::Asset'             => 'AssetPage',
      'Tool::TextDoc'           => 'WikiPage',
      'Tool::Request'           => 'RequestPage',
      'Tool::Event'             => 'EventPage',
      'Tool::TaskList'          => 'TaskListPage',
      'Tool::Message'           => 'MessagePage',
      'Tool::RequestDiscussion' => 'RequestDiscussionPage',
      'Tool::RankedVote'        => 'RankedVotePage',
      'Tool::Info'              => 'InfoPage'
    }
    changes.each do |from, to|
       Page.connection.execute "UPDATE pages SET type = '#{to}' WHERE type = '#{from}'"
    end
  end

  def self.down
    changes = {
      'Tool::Discussion'        => 'DiscussionPage',
      'Tool::RateMany'          => 'RateManyPage',
      'Tool::Asset'             => 'AssetPage',
      'Tool::TextDoc'           => 'WikiPage',
      'Tool::Request'           => 'RequestPage',
      'Tool::Event'             => 'EventPage',
      'Tool::TaskList'          => 'TaskListPage',
      'Tool::Message'           => 'MessagePage',
      'Tool::RequestDiscussion' => 'RequestDiscussionPage',
      'Tool::RankedVote'        => 'RankedVotePage',
      'Tool::Info'              => 'InfoPage'
    }
    changes.each do |to, from|
       Page.connection.execute "UPDATE pages SET type = '#{to}' WHERE type = '#{from}'"
    end
  end
end

