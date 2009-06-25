require "#{File.dirname(__FILE__)}/../../../../test/integration/integration_test_helper"

class GalleryTest < ActionController::IntegrationTest
  def test_create_gallery_with_images
    login 'purple'

    visit '/me/dashboard'
    click_link 'Create Page'
    click_link 'Gallery'

    # withing is not necessary (since the fields names are unique)
    # but is here as an example of how to restrict the scope of actions on the page
    within(".create_page table.form") do |scope|
      scope.fill_in 'page[title]', :with => 'my pictures'
      scope.select 'rainbow', :from => 'page[owner]'
      # TODO: attach_file with a multi item input name is broken.
      # figure out how to fix this
      # might have to wait until Rails 2.3

      # scope.attach_file 'assets[]', "#{RAILS_ROOT}/test/fixtures/assets/0000/0001/bee.jpg", "image/jpeg"
      # scope.attach_file 'assets[]', "#{RAILS_ROOT}/test/fixtures/assets/0000/0002/photo.jpg", "image/jpeg"
    end
    # save_and_open_page
    click_button 'Create Page »'

    assert_contain 'my pictures'
    # assert_contain %r{bee\s*photo}
    # assert_contain %r{Groups\s*rainbow\s*People\s*Purple!}
  end
end
