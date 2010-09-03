I18n.default_locale = "en"
Dir["config/locales/*"].each do |file_name|
  I18n.load_path << file_name
end