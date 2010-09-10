class Admin::TasksController < ApplicationController
  before_filter :restricted_area
  load_and_authorize_resource

  # GET /tasks
  # GET /tasks.xml
  def index
    conditions = ['tasks.id>=0']
    @users = User.with_role(:user)
    @managers = User.with_role(:manager)
    joins = []

    if params[:task]
      @task = Task.new params[:task]
      #session[:activity] = request.request_uri if request.request_uri # || request.env['HTTP_REFERER']
      if @task.manager_id
        conditions[0] << " and tasks.manager_id = ?"
        conditions << @task.manager_id
      end

      if @task.user_id
        #conditions[0] << " and user_id = ?"
        #conditions << @task.user_id
        joins << :users
        conditions[0] << " and tasks_users.user_id = ?"
        conditions << @task.user_id
      end

      if @task.project_id
        conditions[0] << " and tasks.project_id = ?"
        conditions << @task.project_id
      end

      if @task.code
        conditions[0] << " and tasks.code like ?"
        conditions << "%#{@task.code}%"
      end

      if @task.name
        conditions[0] << " and tasks.name like ?"
        conditions << "%#{@task.name}%"
      end

      if @task.description
        conditions[0] << " and tasks.description like ?"
        conditions << "%#{@task.description}%"
      end
    else
      @task = Task.new
    end

    @tasks = Task.paginate :per_page => 10, :page => params[:page], :joins => joins, :include => [:project, :activities], :conditions => conditions, :order => 'tasks.id'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
    end
  end
  

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])
    @activities = @task.activities.find(:all, :select => :hours)
    @tot_hours = @activities.map{|a| a.hours}.inject{|tot,h| tot+h}

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
    end
  end  

  # GET /tasks/new
  # GET /tasks/new.xml
  def new(task=nil)
    @task = task || Task.new
    @users = User.with_role(:user)
    @managers = User.with_role(:manager)

    return if task
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end  

  # POST /tasks
  # POST /tasks.xml
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        manage_to_many(@task, "user")
        @task.set_state_from_users!
        flash[:notice] = I18n.t(:created, :model => I18n.t('models.task'))
        format.html { redirect_to([:admin, @task]) }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        new(@task)
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # GET /tasks/1/edit
  def edit(task=nil)
    @task = task || Task.find(params[:id])
    @users = User.with_role(:user)
    @managers = User.with_role(:manager)
  end
  

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        manage_to_many(@task, "user")
        @task.set_state_from_users!
        flash[:notice] = I18n.t(:updated, :model => I18n.t('models.task'))
        format.html { redirect_to([:admin, @task]) }
        format.xml  { head :ok }
      else
        edit(@task)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    flash[:notice] = I18n.t(:deleted, :model => I18n.t('models.task'))

    respond_to do |format|
      format.html { redirect_to(admin_tasks_url) }
      format.xml  { head :ok }
    end
  end
end
