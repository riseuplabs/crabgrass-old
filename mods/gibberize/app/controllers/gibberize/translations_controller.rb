class Gibberize::TranslationsController < Gibberize::BaseController
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @translation }
    end
  end

  # GET /translations/new
  # GET /translations/new.xml
  def new
#    @translation = Translation.wanted_from current_user
    @translation = Translation.new
    @translation.key = Key.find(params[:key]) if params[:key]
    @translation.language = Language.find(params[:language]) if params[:language]

    @languages = Language.find(:all)
    @keys = Key.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @translation }
    end
  end

  # GET /translations/1/edit
  def edit
    @translation = Translation.find(params[:id])
  end

  # POST /translations
  # POST /translations.xml
  def create
#    @translation = Translation.new(params[:translation].merge(:user => current_user))
    @translation = Translation.new(params[:translation])
    respond_to do |format|
      if @translation.save
        flash[:notice] = 'Translation was successfully created.'
        format.html { redirect_to :action => :new }
        format.xml  { render :xml => @translation, :status => :created, :location => @translation }
      else
        @languages = Language.find(:all)
        @keys = Key.find(:all)
        format.html { render :action => "new" }
        format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /translations/1
  # PUT /translations/1.xml
  def update
    @translation = Translation.find(params[:id])

    respond_to do |format|
      if @translation.update_attributes(params[:translation])
        flash[:notice] = 'Translation was successfully updated.'
        format.html { redirect_to(@translation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @translation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /translations/1
  # DELETE /translations/1.xml
  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy

    respond_to do |format|
      format.html { redirect_to(translations_url) }
      format.xml  { head :ok }
    end
  end
end
