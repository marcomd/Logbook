class AddRolesMaskToUsers < ActiveRecord::Migration
  def self.up
    User.create(:email=>'admin@logbook.it', 
                :password=>'admin',
                :password_confirmation=>'admin'
                :confirmed_at=>Time.now
                :roles=>['admin'])
  end

  def self.down
    User.find_by_email('admin@logbook.it').destroy
  end
end
