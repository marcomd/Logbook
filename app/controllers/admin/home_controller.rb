class Admin::HomeController < ApplicationController
  before_filter :restricted_area

  def index
  end

end
