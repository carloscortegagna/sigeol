class TeachingsController < ApplicationController
  skip_before_filter :login_required, :only => :index
  # GET /teachings
  # GET /teachings.xml
  def index
    @teachings = Teaching.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teachings }
    end
  end

  def administration
    @teachings = Teaching.find(:all)
  end
  

  # GET /teachings/1
  # GET /teachings/1.xml
  def show
    @teaching = Teaching.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teaching }
    end
  end

  # GET /teachings/new
  # GET /teachings/new.xml
  def new
    @teaching = Teaching.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teaching }
    end
  end

  # GET /teachings/1/edit
  def edit
    @teaching = Teaching.find(params[:id])
  end

  # POST /teachings
  # POST /teachings.xml
  def create
    @teaching = Teaching.new(params[:teaching])

    respond_to do |format|
      if @teaching.save
        flash[:notice] = 'Teaching was successfully created.'
        format.html { redirect_to(@teaching) }
        format.xml  { render :xml => @teaching, :status => :created, :location => @teaching }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @teaching.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teachings/1
  # PUT /teachings/1.xml
  def update
    @teaching = Teaching.find(params[:id])

    respond_to do |format|
      if @teaching.update_attributes(params[:teaching])
        flash[:notice] = 'Teaching was successfully updated.'
        format.html { redirect_to(@teaching) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teaching.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teachings/1
  # DELETE /teachings/1.xml
  def destroy
    @teaching = Teaching.find(params[:id])
    @teaching.destroy

    respond_to do |format|
      format.html { redirect_to(teachings_url) }
      format.xml  { head :ok }
    end
  end
end
