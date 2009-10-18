class Translator::TranslationsController < Translator::BaseController

  before_filter :fetch_sites
  # GET /translations
  # GET /translations.xml
  def index
    @translations = Translation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @translations }
    end
  end

  # GET /translations/1
  # GET /translations/1.xml
  def show
    @translation = Translation.find(params[:id])
    render :action => 'edit'
  end

  # GET /translations/new
  # GET /translations/new.xml
  def new
    @translation = Translation.new
    @key = Key.find_by_name(params[:key])
    @language = Language.find_by_code(params[:language])
    @site = Site.find_by_id(params[:site_id])

    if trans = @key.translations.for_site(@site).find_by_language_id(@language.id)
      redirect_to :action => :edit, :id => trans
    else
      @translation.key = @key
      @translation.language = @language
      @translation.site = @site
    end
  end

  # GET /translations/1/edit
  def edit
    @translation = Translation.find(params[:id])
    @site = @translation.site
  end

  # POST /translations
  # POST /translations.xml
  def create
    @translation = Translation.new(params[:translation])
    if @translation.save
      flash_message :success => 'Translation was successfully created.'
      redirect_to :controller => :keys, :language => @translation.language, :filter => 'untranslated'
    else
      flash_message_now :object => @translation
      render :action => 'new'
    end
  end

  # PUT /translations/1
  # PUT /translations/1.xml
  def update
    @translation = Translation.find(params[:id])
    if params[:save]
      if @translation.update_attributes(params[:translation])
        flash_message :success => 'Translation was successfully updated.'
        redirect_to :controller => :keys, :language => @translation.language, :filter => 'untranslated'
      else
        flash_message_now :object => @translation
        render :action => 'edit'
      end
    elsif params[:destroy]
      @translation.destroy
      redirect_to :controller => :keys, :language => @translation.language, :filter => 'translated'
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.xml
  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy
    redirect_to :controller => :keys, :language => @translation.language, :filter => 'translated'
  end

  def translation_file
    language = Language.find_by_code(params[:id])
    translations = Translation.find(:all, :conditions => ["language_id = ?", language.id])
    @buffer = String.new
    translations.each {|t| @buffer << "#{t.key.name}: #{t.text}\n"}
    render :layout => false
  end

  protected
  def fetch_sites

    @sites = Site.all
  end
end
