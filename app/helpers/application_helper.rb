# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  #Get name from first part of email, for ex:
  #marco.mastrodonato@domain.com => Marco Mastrodonato
  def toname(email)
    return unless email
    #restituisce l'email spezzata in due dalla chiocciola
    email.match(/[a-zA-Z][\w\.-]*[a-zA-Z0-9]/).to_s.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join ' '
  end

  #Helper to manage check box's pagination for many to many relations
  def manage_to_many_checkbox(collection, object, str_object_many, cols=1)
    html = ""
    i=0
    collection.each do |item|
      html << "<div style='display: block'>" if i % cols == 0
      id_html = "#{str_object_many}_#{item.id.to_s}"
      html << "<span style='float:left;width: #{100/cols}%;'>" <<
              check_box_tag("#{str_object_many}_ids[]",
                            item.id,
                            object.send("#{str_object_many}s").include?(item),
                            {:id => id_html}) <<
              label_tag(id_html, toname(item.email)) <<
              "</span>"
      i+=1
      html << "</div>" if i % cols == 0
    end
    html << "</div><div class='clear'></div>"
  end

  # Extending calendar_date_select_tag to support i18n
  def calendar_date_select_tag(*args)
    i18n_script = update_page_tag do |page|
      page.assign '_translations', {
        'OK'     => I18n.t('calendar_date_select.ok'),
        'Now'    => I18n.t('calendar_date_select.now'),
        'Today'  => I18n.t('calendar_date_select.today'),
        'Clear' => I18n.t('calendar_date_select.clear')
      }
      page.assign 'Date.weekdays', I18n.translate('date.abbr_day_names').map{|d|d[0..0]}
      page.assign 'Date.months', I18n.translate('date.month_names')[1..-1]
    end

    i18n_script + super(*args)
  end

  #Show a progression bar
  def show_bar(total, partial)
    partial = partial.inject{|tot,h| tot+h} if partial.is_a? Array
    perc = partial.to_f/total.to_f
    bar = case perc
    when 0..0.06 then 0
    when 0..0.27 then 1
    when 0..0.48 then 2
    when 0..0.69 then 3
    when 0..0.90 then 4
    when 0..1.20 then 5
    when 0..1000.00 then 6
    end if total and total > 0
    image_tag("styles/#{STYLE}/bar_#{bar}.gif", {:title => "#{t(:progress)} #{(perc*100).to_i}%"}) if bar
  end

   #Pluralize without the number
   def I18n_pluralize(count, singular, plural = nil)
     ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
   end

end
