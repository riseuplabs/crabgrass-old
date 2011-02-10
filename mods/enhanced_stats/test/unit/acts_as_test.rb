require File.dirname(__FILE__) + '/../test_helper'

class ActsAsTest < ActiveSupport::TestCase

  def test_created_between
    # asserts the method works for all models
    strtime = '%Y-%m-%d'
    ['User', 'Page', 'WikiPage', 'Post', 'Group', 'Committee', 'PageHistory'].each do |thing|
      n = Kernel.const_get(thing).created_between(2.days.ago.strftime(strtime), Time.now.strftime(strtime)).count
      assert n >= 0
    end
  end

end
