require File.dirname(__FILE__) + '/../../../../test/test_helper'

class AssetPageControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites

  @@private = AssetExtension::Storage.private_storage = "#{RAILS_ROOT}/tmp/private_assets"
  @@public = AssetExtension::Storage.public_storage = "#{RAILS_ROOT}/tmp/public_assets"

  def setup
    @request.host = "localhost"

    FileUtils.mkdir_p(@@private)
    FileUtils.mkdir_p(@@public)
    Media::Process::Base.log_to_stdout_when = :on_error
  end

  def teardown
    FileUtils.rm_rf(@@private)
    FileUtils.rm_rf(@@public)
  end

  def test_show
    asset = Asset.create_from_params :uploaded_data => upload_data('photo.jpg')
    page = create_page :data => asset

    @controller.stubs(:login_or_public_page_required).returns(true)
    post :show, :page_id => page.id, :id => 1
    assert_response :success
#    assert_template 'show'
    assert_equal asset.private_filename, assigns(:asset).private_filename,
      "should fetch the correct file"
  end

  def test_create
    login_as :gerrard

    get 'create', :id => AssetPage.param_id

    assert_no_difference 'Asset.count' do
      assert_no_difference 'Page.count' do

        post 'create', :id => AssetPage.param_id,
          :page => {:title => 'test'},
          :asset => {:uploaded_data => ""}
        assert_equal 'error', flash[:type],
          "shouldn't be able to create an asset page with no asset"
      end
    end

    assert_difference 'Thumbnail.count', 6, "image file should generate 6 thumbnails" do
      post 'create', :id => AssetPage.param_id,
        :page => {:title => "title", :summary => ""},
        :asset => {:uploaded_data => upload_data('photo.jpg')}
      assert_response :redirect
    end

  end

  def test_create_same_name
    login_as :gerrard

    data_ids, page_ids, page_urls = [],[],[]
    3.times do
      post 'create', :id => AssetPage.param_id,
        :page => {:title => "dupe", :summary => ""},
        :asset => {:uploaded_data => upload_data('photo.jpg')}
      page = assigns(:page)

      assert_equal "dupe", page.title
      assert_not_nil page.id

      # check that we have:
      # a new asset
      assert !data_ids.include?(page.data.id)
      # a new page
      assert !page_ids.include?(page.id)
      # a new url
      assert !page_urls.include?(page.name_url)

      # remember the values we saw
      data_ids << page.data.id
      page_ids << page.id
      page_urls << page.name_url
    end
  end

  def test_create_in_group
    login_as :blue

    get 'create', :id => AssetPage.param_id

    post 'create', :id => AssetPage.param_id,
      :page => {:title => "title", :summary => ""},
      :asset => {:uploaded_data => upload_data('photo.jpg')},
      :recipients => {'rainbow' => {:access => 'admin'}}
    assert_equal 1, assigns(:page).groups.length,
      "asset page should belong to one group"
    assert_equal groups(:rainbow), assigns(:page).groups.first,
      "asset page should belong to rainbow group"
  end


  def test_update
    login_as :gerrard

    get 'create', :id => AssetPage.param_id
    post 'create', :id => AssetPage.param_id,
      :page => {:title => "title", :summary => ""},
      :asset => {:uploaded_data => upload_data('photo.jpg')}

    assert_difference 'Asset::Version.count', 1, "jpg should version" do
      post 'update', :page_id => assigns(:page).id,
        :asset => {:uploaded_data => upload_data('photo.jpg')}
    end
  end

  def test_updated_by
    asset = Asset.create_from_params(:uploaded_data => upload_data('photo.jpg'))
    page = AssetPage.create :title => 'hi',
      :user => users(:blue),
      :share_with => users(:kangaroo),
      :access => 'edit',
      :data => asset
    assert_equal users(:blue).id, page.updated_by_id

    login_as :kangaroo
    post 'update', :page_id => page.id,
      :asset => {:uploaded_data => upload_data('photo.jpg')}
    assert_equal 'kangaroo', page.reload.updated_by_login
  end

  def test_destroy_version
    login_as :gerrard
    post 'create', :id => AssetPage.param_id,
      :page => {:title => "title", :summary => ""},
      :asset => {:uploaded_data => upload_data('photo.jpg')}

    @asset = assigns(:page).data
    @version_filename = @asset.versions.find_by_version(1).private_filename
    post 'update', :page_id => assigns(:page).id,
      :asset => {:uploaded_data => upload_data('photo.jpg')}
    @page = assigns(:page)
    @asset = @page.data

    @controller.stubs(:login_or_public_page_required).returns(true)
    post :destroy_version, :controller => "asset_page", :page_id => @page.id, :id => 1
    assert_redirected_to @controller.page_url(@page)
    assert File.exists?(@asset.private_filename)
    assert !File.exists?(@version_filename)

    get :show, :page_id => @page.id
    assert_response :success
    assert_equal 1, assigns(:asset).versions.size
  end

  def test_destroy_version_2
    login_as :gerrard
    post 'create', :id => AssetPage.param_id,
      :page => {:title => "title", :summary => ""},
      :asset => {:uploaded_data => upload_data('photo.jpg')}
    post 'update', :page_id => assigns(:page).id,
      :asset => {:uploaded_data => upload_data('photo.jpg')}
    assert_difference 'Asset::Version.count', -1, "destroy should remove a version" do
      post :destroy_version,  :page_id => assigns(:page).id, :id => 1
    end
  end

  def test_generate_preview
    login_as :gerrard

    post 'create', :id => AssetPage.param_id,
      :page => {:title => "title", :summary => ""},
      :asset => {:uploaded_data => upload_data('photo.jpg')}

    assert_difference 'Thumbnail.count', 0,
      "the first time an asset is shown, it should call generate preview" do
      xhr :post, 'generate_preview', :page_id => assigns(:page).id
    end
  end


  protected
  def create_page(options = {})
    defaults = {:title => 'untitled page', :public => false}
    AssetPage.create(defaults.merge(options))
  end
end
