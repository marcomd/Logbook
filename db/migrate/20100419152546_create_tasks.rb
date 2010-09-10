class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|

      t.references :manager

      t.references :user

      t.references :project

      t.string :name

      t.text :description

      t.string :code

      t.integer :expected_hours


      t.timestamps

    end
  end
  
  def self.down
    drop_table :tasks
  end
end
