class Translator::KeysController < Translator::BaseController

  # GET /keys
  def index
    @language = Language.find_by_code(params[:language])
    @filter = params[:filter]
    if @filter == 'search'
      @keys = Key.by_name.paginate(:page => params[:page], :conditions => ['keys.name LIKE ?', "%"+(params[:search]||"")+"%"])
    elsif @language
      redirect_to params.merge(:filter => 'untranslated') unless @filter
      if @filter == 'all'
        @keys = Key.by_name.paginate(:page => params[:page])
      elsif @filter == 'translated'
        @keys = Key.by_name.translated(@language).paginate(:page => params[:page])
      elsif @filter == 'untranslated'
        @keys = Key.by_name.untranslated(@language).paginate(:page => params[:page])
      elsif @filter == 'out_of_date'
        @keys = Key.by_name.out_of_date(@language).paginate(:page => params[:page])
      end
    else
      @keys = Key.by_name.paginate(:page => params[:page])
    end
  end

  # GET /keys/1
  def show
    @key = Key.find_by_name(params[:id], :include => :translations)
    @languages = Language.find(:all)
    @sites = Site.find(:all)
  end

  # GET /keys/new
  def new
    @key = Key.new
  end

  # GET /keys/1/edit
  def edit
    @key = Key.find_by_name(params[:id])
  end

  # POST /keys
  def create
    @key = Key.new(params[:key])
    if @key.save
      flash_message :success => 'Key was successfully created.'
      redirect_to(@key)
    else
      flash_message_now :object => @key
      render :action => "new"
    end
  end

  # PUT /keys/1
  def update
    @key = Key.find_by_name(params[:id])
    if params[:update]
      if @key.update_attributes(params[:key])
        flash_message :success => 'Key was successfully updated.'
        redirect_to(@key)
      else
        flash_message_now :object => @key
        render :action => "edit"
      end
    elsif params[:destroy]
      destroy
    end
  end

  # DELETE /keys/1
  def destroy
    @key = Key.find_by_name(params[:id])
    @key.destroy
    flash_message :success => 'key destroyed'
    redirect_to(keys_path)
  end
end
