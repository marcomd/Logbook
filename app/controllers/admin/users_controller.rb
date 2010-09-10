class Admin::UsersController < ApplicationController
  before_filter :restricted_area
  load_and_authorize_resource

  # GET /users
  # GET /users.xml
  def index
    @users = User.all
   respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end
  

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end  

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end  

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        flash[:notice] = I18n.t(:created, :model => I18n.t('models.user'))
        format.html { redirect_to([:admin, @user]) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end  

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end
  

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    unless params[:user]['password'] && params[:user]['password'].size > 0
      params[:user].delete 'password'
      params[:user].delete 'password_confirmation'
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t(:updated, :model => I18n.t('models.user'))
        format.html { redirect_to([:admin, @user]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = I18n.t(:deleted, :model => I18n.t('models.user'))

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
end
