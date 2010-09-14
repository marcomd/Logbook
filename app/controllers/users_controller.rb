class UsersController < ApplicationController
  load_and_authorize_resource

  # GET /users/1
  # GET /users/1.xml
  def show
    @user ||= User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
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
    #Change password only if it is setted
    unless params[:user]['password'] && params[:user]['password'].size > 0
      params[:user].delete 'password'
      params[:user].delete 'password_confirmation'
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t(:updated, :model => I18n.t('models.user'))
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add_follower
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.followers << current_user
        format.html do
          flash[:notice] = I18n.t(:added_user_to_following, :user => toname(@user.try(:email)))
          redirect_to(@user)
        end
        format.js do
          render "show"
        end
        format.xml  { head :ok }
      else
        format.html do
          flash[:notice] = I18n.t :generic_error
          render "show"
        end
        format.js
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def remove_user_from_following
    @user = current_user
    following_ids = @user.following.map(&:id)
    res = @user.following.delete(User.find params[:id].to_i) if following_ids.include? params[:id].to_i
    respond_to do |format|
      if res
        format.html do
          flash[:notice] = I18n.t(:removed_user_to_following, :user => toname(@user.try(:email)))
          redirect_to(@user)
        end
        format.js do
          render "show"
        end
        format.xml  { head :ok }
      else
        format.html do
          flash[:notice] = I18n.t :generic_error
          render "show"
        end
        format.js do
          render "show"
        end
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end
