class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|

      t.references :task

      t.date :day

      t.integer :hours

      t.text :description


      t.timestamps

    end
  end
  
  def self.down
    drop_table :activities
  end
end
