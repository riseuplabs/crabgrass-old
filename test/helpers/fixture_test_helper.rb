module FixtureTestHelper
  # we use transactional fixtures for everything except page terms
  # page_terms is a different ttable type (MyISAM) which doesn't support transactions
  # this method will reload the original page terms from the fixture files
  def reset_page_terms_from_fixtures
    fixture_path = ActiveSupport::TestCase.fixture_path
    Fixtures.reset_cache
    Fixtures.create_fixtures(fixture_path, ["page_terms"])
  end
end
