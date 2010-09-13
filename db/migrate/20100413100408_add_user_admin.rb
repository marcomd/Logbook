class AddUserAdmin < ActiveRecord::Migration
  def self.up
    admin=User.new(:email=>'admin@logbook.it',
                :password=>'admina',
                :password_confirmation=>'admina',
                :roles=>['admin'])
    admin.update_attributes :confirmed_at=>Time.now if admin.save
  end

  def self.down
    User.find_by_email('admin@logbook.it') do |admin|
      admin.destroy if admin
    end
  end
end
