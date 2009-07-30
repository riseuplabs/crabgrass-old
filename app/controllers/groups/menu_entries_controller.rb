class Groups::MenuEntriesController < ApplicationController
  # GET /menu_entries
  # GET /menu_entries.xml
  def index
    @menu_entries = MenuEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      #format.xml  { render :xml => @menu_entries }
    end
  end

  # GET /menu_entries/1
  # GET /menu_entries/1.xml
  def show
    @menu_entry = MenuEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @menu_entry }
    end
  end

  # GET /menu_entries/new
  # GET /menu_entries/new.xml
  def new
    @menu_entry = MenuEntry.new

    respond_to do |format|
      format.html # new.html.erb
      #format.xml  { render :xml => @menu_entry }
    end
  end

  # GET /menu_entries/1/edit
  def edit
    @menu_entry = MenuEntry.find(params[:id])
  end

  # POST /menu_entries
  # POST /menu_entries.xml
  def create
    @menu_entry = MenuEntry.new(params[:menu_entry])

    respond_to do |format|
      if @menu_entry.save
        flash[:notice] = 'MenuEntry was successfully created.'
        format.html { redirect_to(@menu_entry) }
        #format.xml  { render :xml => @menu_entry, :status => :created, :location => @menu_entry }
      else
        format.html { render :action => "new" }
        #format.xml  { render :xml => @menu_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /menu_entries/1
  # PUT /menu_entries/1.xml
  def update
    @menu_entry = MenuEntry.find(params[:id])

    respond_to do |format|
      if @menu_entry.update_attributes(params[:menu_entry])
        flash[:notice] = 'MenuEntry was successfully updated.'
        format.html { redirect_to(@menu_entry) }
        #format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        #format.xml  { render :xml => @menu_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_entries/1
  # DELETE /menu_entries/1.xml
  def destroy
    @menu_entry = MenuEntry.find(params[:id])
    @menu_entry.destroy

    respond_to do |format|
      format.html { redirect_to(menu_entries_url) }
      #format.xml  { head :ok }
    end
  end
end
