require 'nokogiri'
require 'open-uri'

class Parser
  def parse_item(html)
    doc = Nokogiri::HTML(html)
    items = []

    doc.css('li.l-vacancy').each do |vacancy|
      title = vacancy.css('.title a.vt').text
      description = vacancy.css('.sh-info').text
      location = vacancy.css('.cities').text.strip
      date = vacancy.css('.date').text
      company = vacancy.css('.title strong a.company').text.strip
      link = vacancy.css('.title a.vt').attribute('href').to_s

      items << Item.new(title, description, location, date, company, link)
    end

    items
  end
end

