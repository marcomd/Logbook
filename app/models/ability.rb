class Ability
   include CanCan::Ability

   def initialize(user)
     user ||= User.new

     if user.role? :admin
       can :manage, :all
     else  
       can :read, :all
       if user.role?(:manager)
         can :create, Project
         can :update, Project do |project|
           project.try(:user) == user
         end
         can :manage, Task
       end
       if user.role?(:user)
         can :create, Task
         can :update, Task do |task|
           task.try(:user) == user
         end
         can :create, Activity
         can :update, Activity do |activity|
           activity.try(:user) == user
         end
         can :destroy, Activity do |activity|
           activity.try(:user) == user
         end
       end
     end
   end
end