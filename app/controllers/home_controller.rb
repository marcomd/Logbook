class HomeController < ApplicationController

  def index
    @month = params[:month] || Time.now.month
    @year = params[:year] || Time.now.year
    @month = @month.to_i
    @year = @year.to_i
    date_from = Date.new(@year,@month,1)
    date_to = Date.new(@year,@month,-1)
    conditions = ["(day between ? and ?)"]
    conditions << date_from
    conditions << date_to
    if current_user
      conditions[0] << " and user_id = ?"
      conditions << current_user.id
    end
    activities = Activity.find :all, :select => "day, sum(hours) as hours", :conditions => conditions, :group => "day"
    @reports = {}
    activities.each do |activity|
      day = activity[:day].strftime("%d").to_i
      @reports[day] = activity[:hours]
    end

    #date_from = Date.new(Time.now.year,Time.now.month,Time.now.day)
    date_from = Date.new(@year,@month,1)
    date_to = Date.new(@year,@month,-1)
    conditions = ["(day between ? and ?)"]
    conditions << date_from
    conditions << date_to
    @activities = Activity.find :all, :include => [:task => :project], :conditions => conditions, :limit => 10, :order => 'created_at DESC'
  end

end
