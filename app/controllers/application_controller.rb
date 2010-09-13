# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :localizate
  before_filter :authenticate_user!

  layout proc{ |c| c.request.xhr? ? false : "application" }

  def localizate
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale] if session[:locale]
  end

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  rescue_from CanCan::AccessDenied do |exception|  
    flash[:error] = I18n.t :permission_denied
    redirect_to root_url
  end

  def restricted_area
    raise CanCan::AccessDenied unless current_user.role? :admin
  end

  def manage_to_many(object, *str_related_models)
    str_related_models.each do |str_model|
      model = eval str_model.capitalize
      str_model_plural = "#{str_model}s"
      now = object.send(str_model_plural).map(&:id)
      if params["#{str_model}_ids"]
        selected = params["#{str_model}_ids"].map{|item| item.to_i}
        to_delete = now - selected
        to_add = selected - now
        object.send(str_model_plural).delete(model.find(to_delete)) if to_delete.any?
        object.send(str_model_plural) << model.find(to_add) if to_add.any?
      else
        object.send(str_model_plural).delete_all if now.any?
      end
    end
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
