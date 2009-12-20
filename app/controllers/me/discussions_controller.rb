class Me::DiscussionsController < Me::BaseController
  before_filter :fetch_discussion, :except => [:index, :unread, :new]
  before_filter :prepare_discussions_list, :only => [:index, :unread]

  verify :xhr => true, :only => :mark
  rescue_from ActiveRecord::RecordInvalid, :with => :invalid_discussion

  # GET /me/discussions
  def index
    @discussions = current_user.discussions.from(params[:from]).paginate(page_params)
  end

  # GET /me/discussions/unread
  def unread
    @discussions = current_user.discussions.unread.from(params[:from]).paginate(page_params)
    render :action => 'index'
  end

  # POST /me/discussions
  def create
    @discussion = current_user.discussions.build(params[:discussion])
    @discussion.save!

    redirect_to @discussion
  end

  # AJAX PUT /me/discussions/mark
  def mark
    mark_as = params[:as].to_sym
    # load several discusssions
    @discussions = current_user.discussions.find(params[:discussions])
    @discussions.each do |discussion|
      discussion.mark!(:as => mark_as, :by => :current_user)
    end
  end


  ### REDIRECT ACTIONS ###

  def next
    redirect_to @discussion.next_for(current_user) || :index
  end

  def previous
    redirect_to @discussion.previous_for(current_user) || :index
  end


  ### NOT IMPLEMENTED ###

  # TODO: remove from routes.rb with rails2.3
  def new;raise "Not implemented";end
  def show;raise "Not implemented";end
  def update;raise "Not implemented";end

  protected

  # trying to do discussion.save! has raised RecordInvalid
  # ether when trying to create a new discussion or trying to update an existing one
  def invalid_discussion(exception)
    flash_message :exception => exception
    redirect_to :index
  end

  def prepare_discussions_list
    @discussion = current_user.private_discussions.find(params[:id])
  end

  def prepare_discussions_list
    @discussions = current_user.private_discussions.paginate(page_params)
    @new_discussion = current_user.discussions.build
  end

  def page_params
    {:page => params[:page]}
  end

end
