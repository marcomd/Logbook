class Activity < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  attr_accessible :task_id, :day, :hours, :description
end
