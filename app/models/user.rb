class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :registerable, :authenticatable, :confirmable, :recoverable,
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :confirmed_at, :roles

  has_and_belongs_to_many :tasks

  #People who follow you
  has_and_belongs_to_many :followers,
                          :class_name => "User",
                          :join_table => "followers_users",
                          :association_foreign_key => "follower_id"
  #Who are you following
  has_and_belongs_to_many :following,
                          :class_name => "User",
                          :join_table => "followers_users",
                          :foreign_key => "follower_id",
                          :association_foreign_key => "user_id"
  
  has_many :projects, :dependent => :nullify

  has_many :owner_user_tasks,
           :class_name => "Task",
           :foreign_key => "user_id",
           :dependent => :nullify

  has_many :owner_manager_tasks,
           :class_name => "Task",
           :foreign_key => "manager_id",
           :dependent => :nullify

  named_scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }
  ROLES = %w[admin manager user guest]
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end
  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end
  def role_symbols
    roles.map(&:to_sym)
  end
  def role?(role)
    roles.include? role.to_s
  end
end
