class Project < ActiveRecord::Base
  attr_accessible :user, :name, :description

  belongs_to :user
  has_many :tasks, :dependent => :nullify
end
