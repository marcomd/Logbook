class CreateTasksUsers < ActiveRecord::Migration
  def self.up
    create_table :tasks_users, :id => false do |t|
      t.belongs_to :task
      t.belongs_to :user

      t.timestamps
    end
    add_index :tasks_users, :task_id
    add_index :tasks_users, :user_id
  end

  def self.down
    remove_index :tasks_users, :task_id
    remove_index :tasks_users, :user_id
    drop_table :roles_users
  end
end
