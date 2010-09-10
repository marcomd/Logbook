# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

namespace :db do
  namespace :import do
    desc "Import tasks from file txt"
    task(:tasks => :environment) do
      task_name = "db:import:tasks"
      DATA_DIRECTORY = File.join(RAILS_ROOT, "lib", "tasks", "files")
      time = Time.now
      puts "--- #{time.strftime("%Y %m %d %H:%M:%S")} Starting #{task_name}, please wait... ---"
      discards = []
      num_new = num_upd = 0
      begin
        #Looking for a file called tasks_yyyymmdd.txt into lib/tasks/files
        File.open(File.join(DATA_DIRECTORY, "tasks_#{time.strftime("%Y%m%d")}.txt"), 'r') do |f|
          while rec = f.gets
            #Build the key to check into db
            #These are find conditions
            conditions = []
            conditions << "code = ?"
            conditions << rec[6..17]

            #if record exists, we update its informations otherwise we insert a new one
            task = Task.find(:first, :conditions => conditions) || Task.new
            new_record = task.new_record?

            task.project_id = rec[0..2].to_i
            task.manager_id = rec[3..5].to_i
            task.expected_hours = rec[18..22].to_i
            task.code = conditions[1] if new_record
            task.name = rec[23..82]
            task.description = rec[83..-1]
            task.state_id = 

            if task.save
              new_record ? num_new += 1 : num_upd += 1
            else
              discards << rec
            end
          end
        end

        puts "--- #{Time.now.strftime("%Y %m %d %H:%M:%S")} Process completed! %i second(s) elapsed  ---" % (Time.now - time)
        puts "Task loaded: #{num_new.to_s}"
        puts "Task updated: #{num_upd.to_s}"
        puts "Discarded: #{discards.size}" if discards.size > 0

        if discards.any?
          #Scrivo il file degli scarti
          File.open(File.join(DATA_DIRECTORY, "tasks_discards_#{time.strftime("%Y%m%d_%H%M%S")}.txt"), 'w') {|f| f.write discards.join}
          raise "Sono presenti degli scarti, verificare!"
        end

        Notifier.deliver_admin_notification :result => true, :task => task_name
      rescue StandardError => err
        puts err.message
        Notifier.deliver_admin_notification :result => false, :task => task_name, :message => err.message
        exit(9)
      end
    end

    desc "Import all files!"
    task(:all => [:projects, :tasks, :activities]) do
      puts "*" * 40
      puts "Congratulations! All tasks completed."
      puts "*" * 40
    end
  end
end

namespace :batch do
  namespace :check do
    desc "Check if task should be closed"
    task(:tasks, :needs => :environment) do |task_name|
      time = Time.now
      puts "--- #{time.strftime("%Y %m %d %H:%M:%S")} Starting #{task_name}, please wait... ---"
      DEBUG = true

      bol_task = false
      Task.transaction do
        begin
          discards = []
          num_new = num_upd = 0

          tasks = Task.open.including(:user).select do |task|
            begin
              rec = "#{discard.record.ljust(23)}#{'%017i' % discard.container.name}#{'%03i' % discard.page}"
              ret_new, ret_upd, ret_discard, str_discard = scan(rec, discard)
              num_new += ret_new; num_upd += ret_upd; num_discard += ret_discard
              true
            rescue StandardError => err
              discard.update_attributes(:state_id => State::ERROR,
                                        :description => err.message)
              false
            end
          end
          if discards.any?
            Discard.update_all("state_id=#{State::COMPLETED}",
                              ["id in (?) and state_id = ?",
                                discards.map(&:id),
                                State::RECYCLED]
                            )
          end

          puts "--- #{Time.now.strftime("%Y %m %d %H:%M:%S")} Process completed! %i second(s) elapsed  ---" % (Time.now - time)
          puts "Receipts loaded: #{num_new.to_s}"
          puts "Receipts updated: #{num_upd.to_s}"
          puts "Scans discarded: #{num_discard.to_s}" if num_discard > 0
          bol_task = true
        rescue StandardError => err
          puts "Error " << err.message if DEBUG
          notice(Recipient.new(:result=>false,:task=>task_name,:message=>err.message))
          raise ActiveRecord::Rollback
        end
      end
      bol_task ? exit(0) : exit(9)
    end
  end
end

#Send email with outcome
def notifier_to_users(recipients, task)
  recipients.each do |recipient, outcome|
    if recipient =~ /#{SEND_EMAILS_ONLY_FOR_DOMAIN}/
      puts "Sending email to #{recipient}..."
      begin
        Notifier.deliver_user_notification(recipient, outcome, task)
      rescue StandardError => err
        puts err.message
      end
    else
      puts "Email to #{recipient} not sent"
    end
  end
end
#Check if address is included in the list. If not, is added and outcome counter is increased.
#These adresses will be noticied by email.
def add_address(address, tag, list)
  list[address] = {} unless list[address]
  list[address][tag] ? list[address][tag] += 1 : list[address][tag] = 1
end