require File.dirname(__FILE__) + '/../test_helper'
require 'mailer'

class MailerTest < ActiveSupport::TestCase
  fixtures :users, :pages, :groups, :sites
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @page = nil
    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end

  def test_share_page
    user = users(:green)
    @page = pages(:page1)
    response = Mailer.create_share_notice(user, 'hey you, check out the page', mailer_options)
    assert_match /#{Regexp.escape(@page.title)}/, response.subject
    assert_match /#{Regexp.escape(@page.uri)}/, response.body
    assert_equal user.email, response.to[0]
  end

  def test_request_to_join_us
    insider  = users(:dolphin)
    group    = groups(:animals)

    req = RequestToJoinUsViaEmail.create(
      :created_by => insider, :email => 'root@localhost', :requestable => group)
    response = Mailer.create_request_to_join_us(req, mailer_options)
    assert_match /#{Regexp.escape(req.group.display_name)}/, response.subject
    assert_match /#{Regexp.escape(req.group.display_name)}/, response.body
    assert_match /#{Regexp.escape(req.code)}/, response.body
    assert_match /#{Regexp.escape(req.email.gsub('@','_at_'))}/, response.body
    assert_equal req.email, response.to[0]
  end


  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end

end


