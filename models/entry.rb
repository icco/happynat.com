class Entry < Sequel::Model(:entries)
  def html

    html = UrlParser.getUrls(self.text).map {|url| UrlParser.transformUrl(url) }.join(" ")

    return self.text + html
  end

  def self.send_reminder
    # Mail Settings
    Pony.options = {
      :via => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    }

    month = Time.now.month
    day   = Time.now.day
    year  = Time.now.year

    entry_count = Entry.filter(
      'create_date >= ? and create_date < ?',
      Chronic.parse("#{month}/#{day}/#{year}"),
      Chronic.parse("#{month}/#{day+1}/#{year}")
    ).count

    if entry_count < 1
      Pony.mail(
        :from => "server@happynat.com",
        :to => "nat@natwelch.com",
        :subject => "What makes you happy on #{Time.now.strftime("%D")}?",
        :html_body => File.read('views/mail.erb')
      )

      return true
    end

    return false
  end
end

