class TasksController < ApplicationController
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
      if current_user.role? :manager
        @task.manager_id = current_user.id
        conditions[0] << " and tasks.manager_id = ?"
        conditions << @task.manager_id
      elsif current_user.role? :user
        @task.user_id = current_user.id
        conditions[0] << " and tasks.user_id = ?"
        conditions << @task.user_id
      end
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
    @tot_hours = @activities.map{|a| a.hours}.inject{|tot,h| tot+h} || 0
#    @show_bar = case @tot_hours.to_f/@task.expected_hours.to_f
#    when 0 then 0
#    when 0..0.23 then 1
#    when 0..0.46 then 2
#    when 0..0.69 then 3
#    when 0..0.92 then 4
#    when 0..1.20 then 5
#    when 0..1000.00 then 6
#    end if @task.expected_hours && @task.expected_hours > 0

    respond_to do |format|
      format.html # show.html.erb
      format.js
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
    @task.user_id = current_user.id unless @task.user_id
    @task.manager_id = current_user.id unless @task.manager_id

    respond_to do |format|
      if @task.save
        manage_to_many(@task, "user")
        @task.set_state_from_users!
        flash[:notice] = I18n.t(:created, :model => I18n.t('models.task'))
        format.html { redirect_to(@task) }
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
    #@task.user_id = current_user.id unless current_user.role? :admin

    respond_to do |format|
      if @task.update_attributes(params[:task])
        manage_to_many(@task, "user")
        @task.set_state_from!
        flash[:notice] = I18n.t(:updated, :model => I18n.t('models.task'))
        format.html { redirect_to(@task) }
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
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
  end

  def select
    if params[:select]
      @tasks = Task.find(params[:select], :include => [:project, :activities])
      @operation = params[:operation]
      @results = {}
      @tasks.each do |task|
        begin
          case @operation
          when I18n.t('attributes.task.events.close')
            task.close!
            @results[task.id] = [true, "Chiusura effettuata!"]
            #task.errors.map{|k,v| "#{k}: #{v}"}.join(', ')
          when I18n.t('attributes.task.events.cancel')
            task.cancel!
            @results[task.id] = [true, "Cancellazione effettuata!"]
          when I18n.t('attributes.task.events.open')
            task.reopen!
            @results[task.id] = [true, "Riapertura effettuata!"]
          end
        rescue
          @results[task.id] = [false, "Operazione non consentita. Elenco operazioni: #{task.state_events.map{|e|t "attributes.task.events.#{e.to_s}"}.join(', ')}"]
        end
      end

      respond_to do |format|
        format.js do
        end
      end
    end
    @tasks ||= []
  end

end