class HomeController < ApplicationController

  def index
    @month = params[:month] || Time.now.month
    @year = params[:year] || Time.now.year
    @month = @month.to_i
    @year = @year.to_i
    date_from = Date.new(@year,@month,1)
    date_to = Date.new(@year,@month,-1)
    condition = ["(day between ? and ?)"]
    condition << date_from
    condition << date_to
    if current_user
      condition[0] << " and user_id = ?"
      condition << current_user.id
    end
    activities = Activity.find :all, :select => "day, sum(hours) as hours", :conditions => condition, :group => "day"
    @reports = {}
    activities.each do |activity|
      day = activity[:day].strftime("%d").to_i
      @reports[day] = activity[:hours]
    end
  end

end
