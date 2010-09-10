class Notifier < ActionMailer::Base
  #layout 'application'

  def admin_notification(args={})
     args[:name] = 'amministratore'
     emails = User.with_role('admin').map(&email) + args[:emails]
     recipients emails.join(',')
     from "#{APPLICATION_NAME} <CyberMail@ergoitalia.it>"
     subject args[:task] || "Notice"
     sent_on Time.now
     body :args => args
     #content_type "text/html"
  end

  def user_notification(args={})
     recipients args[:address]
     from "#{APPLICATION_NAME} <CyberMail@ergoitalia.it>"
     subject args[:task] || "Notice"
     sent_on Time.now
     body :args => args
     #content_type "text/html"
  end
end