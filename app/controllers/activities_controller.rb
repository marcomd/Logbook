class ActivitiesController < ApplicationController
  load_and_authorize_resource

  # GET /activities
  # GET /activities.xml
  def index
    conditions = ['activities.id>=0']
    joins = []
    @activity = Activity.new params[:activity]
    @task = Task.new params[:task]
    date_format = '%d/%m/%Y'
    
    if params[:code]
      #Modalità consultazione attività di un daterminato incarico
      @code = params[:code]
    elsif params[:date_from] or params[:date_to]
      if params[:date_from] and params[:date_from].length>0
        date_from = Date.strptime(params[:date_from], date_format)
      end
      if params[:date_to] and params[:date_to].length>0
        date_to = Date.strptime(params[:date_to], date_format)
      end
      date_from ||= Date.strptime('01/01/2010', date_format)
      date_to ||= date_from + 30
      session[:date_from] = {:year => date_from.year, :month => date_from.month, :day => date_from.day}
      session[:date_to] = {:year => date_to.year, :month => date_to.month, :day => date_to.day}
    elsif params[:year] or params[:month] or params[:day]
      day_from = params[:day] || 1
      day_to = params[:day] || -1
      month_from = params[:month] || 1
      month_to = params[:month] || 12
      year_from = params[:year] || 2010
      year_to = params[:year] || 2030

      session[:date] = {:year => params[:year], :month => params[:month], :day => params[:day]} if params[:day]
      session[:date_from] = {:year => year_from, :month => month_from, :day => day_from}
      session[:date_to] = {:year => year_to, :month => month_to, :day => day_to}
      date_from ||= Date.new(session[:date_from][:year].to_i, session[:date_from][:month].to_i, session[:date_from][:day].to_i)
      date_to ||= Date.new(session[:date_to][:year].to_i, session[:date_to][:month].to_i, session[:date_to][:day].to_i)
    elsif session[:date_from] or session[:date_to]
      #Si utilizzano le date memorizzate
      date_from ||= Date.new(session[:date_from][:year].to_i, session[:date_from][:month].to_i, session[:date_from][:day].to_i) if session[:date_from]
      date_to ||= Date.new(session[:date_to][:year].to_i, session[:date_to][:month].to_i, session[:date_to][:day].to_i) if session[:date_to]
    else
      date_to = Date.new(Time.now.year,Time.now.month,Time.now.day)
      date_from = date_to - 30
    end

#    if params[:activity]
#      #session[:activity] = request.request_uri if request.request_uri # || request.env['HTTP_REFERER']
#      description = params[:activity][:description] if params[:activity][:description].length>0
##      if params[:activity]['day(1i)'].length>0
##        day = Date.new(params[:activity]['day(1i)'].to_i,
##                                  params[:activity]['day(2i)'].to_i,
##                                  params[:activity]['day(3i)'].to_i)
##      end
#    end

    if current_user and !@code
      conditions[0] << " and activities.user_id = ?"
      conditions << current_user.id
    end

    if @task.code and @task.code.any?
      conditions[0] << " and tasks.code like ?"
      conditions << "%#{@task.code}%"
      joins << :task
    elsif @code
      conditions[0] << " and tasks.code = ?"
      conditions << @code
      joins << :task
    end

    if @activity.description and @activity.description.any?
      conditions[0] << " and activities.description like ?"
      conditions << "%#{@activity.description}%"
    end

    if date_from and date_to
      conditions[0] << " and activities.day between ? and ?"
      conditions << date_from
      conditions << date_to
      @str_date_from = date_from.strftime(date_format)
      @str_date_to = date_to.strftime(date_format)
    end

    @activities = Activity.paginate :per_page => 50, :page => params[:page], :include => [:task, :user], :joins => joins, :conditions => conditions, :order => 'activities.id'
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @activities }
    end
  end
  

  # GET /activities/1
  # GET /activities/1.xml
  def show
    @activity = Activity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity }
    end
  end  

  # GET /activities/new
  # GET /activities/new.xml
  def new
    @activity = Activity.new
    if session[:date]
      @activity.day = Date.new(session[:date][:year].to_i, session[:date][:month].to_i, session[:date][:day].to_i)
    else
      @activity.day = Date.new(Time.now.year,Time.now.month,Time.now.day)
    end
    @tasks = Task.summarizable

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end  

  # POST /activities
  # POST /activities.xml
  def create
    @activity = Activity.new(params[:activity])
    @activity.user_id = current_user.id
    outcome = true
    respond_to do |format|
      @activity.transaction do
        begin
          raise nil unless @activity.save
          @activity.task.set_state_from_activities!
        rescue => err
          outcome = nil
          flash[:error] = err.message #errors.map{|attr, type| I18n.t(type, :field => attr)}.join(', ')
          raise ActiveRecord::Rollback
        end
      end
      if outcome
        flash[:notice] = I18n.t(:created, :model => I18n.t('models.activity'))
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
    @tasks = Task.summarizable
  end
  

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    @activity = Activity.find(params[:id])
    @activity.user_id = current_user.id unless current_user.roles.include? "admin"

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = I18n.t(:updated, :model => I18n.t('models.activity'))
        format.html { redirect_to(@activity) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy
    flash[:notice] = I18n.t(:deleted, :model => I18n.t('models.activity'))

    respond_to do |format|
      format.html { redirect_to(activities_url) }
      format.xml  { head :ok }
    end
  end
end
