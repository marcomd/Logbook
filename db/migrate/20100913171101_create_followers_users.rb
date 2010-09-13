class CreateFollowersUsers < ActiveRecord::Migration
  def self.up
    create_table :followers_users, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :follower

      t.timestamps
    end
    add_index :followers_users, :user_id
    add_index :followers_users, :follower_id
  end

  def self.down
    remove_index :followers_users, :user_id
    remove_index :followers_users, :follower_id
    drop_table :followers_users
  end
end
