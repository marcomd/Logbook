mailer_options = YAML.load_file("#{Rails.root}/config/mailer.yml")
ActionMailer::Base.smtp_settings = mailer_options
