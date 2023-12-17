require_relative 'parser'
require_relative 'cart'
require 'bundler/setup'
require 'fileutils'
require 'faraday'



class MainApplication
  attr_accessor :username, :password, :data_path

  def initialize(username, password, data_path)
    @username = username
    @password = password
    @data_path = data_path
  end

  def run
    url = 'https://jobs.dou.ua/first-job/'
    timestamp = "dou_#{Time.now.strftime('%Y_%m_%d_%H-%M')}"

    puts "1. Виконання запиту за URL: #{url}"
    html_data = fetch_data(url)

    puts "2. Парсинг HTML-даних"
    parser = Parser.new
    items = parser.parse_item(html_data)

    puts "3. Додавання елементів до сховища"
    cart = Cart.new
    items.each { |item| cart.add_item(item) }

    puts "4. Кількість елементів знайдено: #{cart.count_items}"

    FileUtils.mkdir_p(File.join(data_path, 'out'))
    puts "5. Збереження у різних форматах, формування файлів"
    items.each { |item| cart.add_item(item) }
    cart.save_to_file(File.join(data_path, 'out', "#{timestamp}.txt"))
    cart.save_to_json(File.join(data_path, 'out', "#{timestamp}.json"))
    cart.save_to_csv(File.join(data_path, 'out', "#{timestamp}.csv"))
  end

  def fetch_data(url)
    connection = Faraday.new(url: url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    response = connection.get('')
    response.body
  end
end
