class ProjectsController < ApplicationController
  load_and_authorize_resource

  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.all
   respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end
  

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
#      format.pdf do
#        render  :pdf => "file_name",
#                :template => "projects/show.html.erb",
#                :wkhtmltopdf => 'c:/Programmi/wkhtmltopdf/wkhtmltopdf.exe'
#      end
      format.pdf do
        render :pdf => "file_name",
               :template => "projects/show.html.erb",
               :stylesheets => ["application","prince"],
               :layout => "pdf"
      end
    end
  end  

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end  

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])
    @project.user_id = current_user.id

    respond_to do |format|
      if @project.save
        flash[:notice] = I18n.t(:created, :model => I18n.t('models.project'))
        format.html { redirect_to(@project) }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end
  

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])
    #@project.user_id = current_user.id #unless current_user.role? :admin

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = I18n.t(:updated, :model => I18n.t('models.project'))
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    flash[:notice] = I18n.t(:deleted, :model => I18n.t('models.project'))

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
