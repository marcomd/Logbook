class Task < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :users
  belongs_to :manager,
             :class_name => "User",
             :foreign_key => "manager_id"
  belongs_to :project

  has_many :activities, :dependent => :nullify

  attr_accessible :manager_id, :user_id, :project_id, :name, :description, :code, :expected_hours

  named_scope :summarizable, :conditions => {:state => [2,3]}

#  STATE_NEW = 1.freeze
#  STATE_ASSIGNED = 2.freeze
#  STATE_WORKING = 3.freeze
#  STATE_CLOSED = 4.freeze
#  STATE_DELETED = 5.freeze
#  STATES = [['new', STATE_NEW], ['assigned', STATE_ASSIGNED], ['working', STATE_WORKING], ['closed', STATE_CLOSED], ['deleted', STATE_DELETED]].freeze

  state_machine :state, :initial => :new do
    state :deleted, :value => 0
    state :new, :value => 1
    state :assigned, :value => 2
    state :working, :value => 3
    state :freezed, :value => 4
    state :closed, :value => 5

    event :assign do
      transition :new => :assigned
    end
    event :free do
      transition :assigned => :new
    end
    event :work do
      transition :assigned => :working
    end
    event :unload do
      transition [:working, :freezed] => :assigned
    end
    event :freeze do
      transition :working => :freezed
    end
    event :defreeze do
      transition :freezed => :working
    end
    event :close do
      transition :working => :closed
    end
    event :cancel do
      transition all - [:closed] => :deleted
    end
    event :open do
      transition [:closed, :deleted] => :new
    end
  end

  def set_state_from_users!
    self.assign! if self.new? and self.users.count > 0
    self.free! if self.assigned? and self.users.count == 0
  end

  def set_state_from!
    self.assign! if self.new? and self.users.count > 0
    self.free! if self.assigned? and self.users.count == 0
    self.work! if self.assigned? and self.activities.count > 0
    self.defreeze! if self.freezed? and self.users.count > 0
    if self.working?
      if self.activities.count == 0
        self.unload!
        set_state_from!
      elsif self.users.count == 0 and self.activities.count > 0
        self.freeze!
      end
    end
  end

#  def set_state(new_state)
#    state = new_state || self.state_name
#
#    case state
#    when :new
#      to_set = set_state(:assigned) if self.users.count > 0
#    when :assigned
#      if self.users.count == 0
#        to_set = set_state(:new)
#      elsif self.activities.count > 0
#        to_set = set_state(:working)
#      end
#    when :working
#      if self.activities.count == 0
#        to_set = set_state(:assigned)
#      end
#    end
#
#    return new_state if new_state
#
#    case state
#    when :new
#      state = set_state(:assigned) if self.users.count > 0
#    when :assigned
#      if self.users.count == 0
#        state = set_state(:new)
#      elsif self.activities.count > 0
#        state = set_state(:working)
#      end
#    when :working
#      if self.activities.count == 0
#        state = set_state(:assigned)
#      end
#    end
#  end

  def reopen!
    self.open!
    set_state_from!
  end

#  after_transition any => :new do |task, transition|
#    task.users.delete_all
#  end
#
#  def assign_to_user(user_id)
#    self.user_id = user_id
#    self.assign
#  end
#  def add_users(*users)
#    self.users << users
#    self.assign if self.new?
#  end
#  def remove_users(*users)
#    self.users.delete User.find(users)
#    self.free if self.users.count == 0
#  end
#  def do_free(*users)
#    self.users.delete User.find(users)
#    self.free if self.users.count == 0
#  end
#  def do_free_all
#    self.user_id = nil
#    self.users.delete_all
#    self.free
#  end

end
