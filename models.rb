# All of the models used by happynat

class Entry < Sequel::Model(:entries)
  def html
    markdown = RDiscount.new(
      self.text,
      :smart,
      :filter_html
    )

    return markdown.to_html
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

# The goal of this class is to provide an easy way to transform links into
# images, videos and flash embeds.
class UrlParser

  # Given a block of text, return an array of urls contained within.
  def self.getUrls text
    protocols = %w[http https ftp]

    return protocols.map {|pr| URI::extract(text, pr) }.flatten.compact
  end

  # Given an URL, return html of the content the URL represents, or an empty
  # string.
  def self.transformUrl url

    return ""
  end
end

# Nice time printing
class Time
  def humanize
    if Time.now.strftime("%F") == self.strftime("%F")
      return self.strftime("%l:%M %P")
    elsif Time.now.year == self.year
      return self.strftime("%l%P, %b %e")
    else
      return self.strftime("%b %e '%y")
    end
  end
end
