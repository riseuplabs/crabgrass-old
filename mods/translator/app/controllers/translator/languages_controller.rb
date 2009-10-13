class Translator::LanguagesController < Translator::BaseController
  # GET /languages
  # GET /languages.xml
  def index
    @languages = Language.find(:all)
  end

  # GET /languages/1
  # GET /languages/1.xml
  def show
    @language = Language.find_by_code(params[:id])
    render :action => 'edit'
  end

  # GET /languages/new
  # GET /languages/new.xml
  def new
    @language = Language.new
  end

  # GET /languages/1/edit
  def edit
    @language = Language.find_by_code(params[:id])
  end

  # POST /languages
  # POST /languages.xml
  def create
    @language = Language.new(params[:language])

    if @language.save
      flash_message :success => 'Language created.'
      redirect_to(languages_path)
    else
      render :action => 'new'
      flash_message_now :object => @language
    end
  end

  # PUT /languages/1
  # PUT /languages/1.xml
  def update
    @language = Language.find_by_code(params[:id])

    if @language.update_attributes(params[:language])
      flash_message :success => 'Language was successfully updated.'
      redirect_to(languages_path)
    else
      render :action => 'edit'
      flash_message :object => @language
    end
  end

  # DELETE /languages/1
  # DELETE /languages/1.xml
  def destroy
    @language = Language.find_by_code(params[:id])
    @language.destroy
    redirect_to(languages_path)
  end
end
