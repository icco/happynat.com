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

    uri = URI.parse url

    case url.host
    when /*twitter\.com/
      # do an api call to twitter
    end

    return "<a href=\"#{url}\">#{url}</a>"
  end
end
