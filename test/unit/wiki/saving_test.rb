module Wiki::SavingTest
  def self.included(base)
    base.instance_eval do

      context "A new Wiki locked by an user" do
        setup do
          @wiki = Wiki.create :body => 'watermelon'
          @wiki.lock! :document, users(:blue)
        end

        should "update document for that user" do
          assert_nothing_raised {@wiki.update_document!(users(:blue), 1, 'cantelope')}
          assert_equal 'cantelope', @wiki.reload.body
        end

        should "fail update document when the version is too old" do
          assert_raises(ErrorMessage) {@wiki.update_document!(users(:blue), 0, 'cantelope')}
          assert_equal 'watermelon', @wiki.reload.body
        end

        should "update document when the version is too new" do
          assert_nothing_raised {@wiki.update_document!(users(:blue), 3, 'cantelope')}
          assert_equal 'cantelope', @wiki.reload.body
        end

        should "update document when the version is nil" do
          assert_nothing_raised {@wiki.update_document!(users(:blue), nil, 'cantelope')}
          assert_equal 'cantelope', @wiki.reload.body
        end

        should "fail to update document for a different user" do
          assert_raises(WikiLockError) {@wiki.update_document!(users(:green), 1, 'cantelope')}
          assert_equal 'watermelon', @wiki.reload.body
        end
      end

      context "A new multisection Wiki locked by an user" do
        setup do
          @wiki = Wiki.create :body => "h1. watermelon\n\nh2. seedless"
          @wiki.lock! :document, users(:blue)
        end

        should "be able to get section markup" do
          assert_equal "h2. seedless", @wiki.get_body_for_section('seedless')
        end

        should "update a section for that user" do
          assert_nothing_raised {@wiki.update_section!('watermelon', users(:blue), 1, 'h1. cantelope')}
          assert_equal "h1. cantelope", @wiki.reload.body
        end

        should "fail to update a section for a different user" do
          assert_raises(WikiLockError) {@wiki.update_section!('watermelon', users(:red), 1, 'h1. cantelope')}
          assert_equal "h1. watermelon\n\nh2. seedless", @wiki.reload.body
        end
      end
    end
  end
end

