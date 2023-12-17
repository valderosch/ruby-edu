require 'nokogiri'
require 'open-uri'
require 'json'

class DataParser
  attr_reader :items

  def initialize(url)
    @url = url
    @items = []
  end

  def parse
    page = Nokogiri::HTML(URI.open(@url))

    page.css('div.vacancy').each do |vacancy|
      item = {
        date: vacancy.css('.date').text.strip,
        title: vacancy.css('.title a.vt').text.strip,
        company: vacancy.css('.title strong a.company').text.strip,
        city: vacancy.css('.cities').text.strip,
        description: vacancy.css('.sh-info').text.strip,
        link: vacancy.css('.title a.vt').attribute('href').to_s
      }

      @items << item
    end
  end

  def save_to_json(file_path)
    File.open(file_path, 'w') do |file|
      file.write(JSON.pretty_generate(@items))
    end
  end
end


url = 'https://jobs.dou.ua/first-job/'
parser = DataParser.new(url)
parser.parse
parser.save_to_json('parsed_data.json')

