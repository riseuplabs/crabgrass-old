require File.dirname(__FILE__) + '/../../../../test/test_helper'

class GalleryTest < ActionController::IntegrationTest
  def test_create_gallery_with_images
    login 'purple'

    visit '/me/pages'
    click_link I18n.t(:contribute_content_link) 
    click_link 'Gallery'

    # within is not necessary (since the fields names are unique)
    # but is here as an example of how to restrict the scope of actions on a page
    within(".create_page table.form") do |scope|
      scope.fill_in 'Title', :with => 'my pictures'

      scope.select 'rainbow', :from => 'Page Owner'
      # TODO: attach_file with a multi item input name is broken.
      # figure out how to fix this
      # might have to wait until Rails 2.3

      # scope.attach_file 'assets[]', "#{RAILS_ROOT}/test/fixtures/assets/0000/0001/bee.jpg", "image/jpeg"
      # scope.attach_file 'assets[]', "#{RAILS_ROOT}/test/fixtures/assets/0000/0002/photo.jpg", "image/jpeg"
    end
    click_button 'Create Page »'

    assert_contain 'my pictures'
    # assert_contain %r{bee\s*photo}
    # assert_contain %r{Groups\s*rainbow\s*People\s*Purple!}
  end
end
