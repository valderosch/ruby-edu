require_relative 'item'
require_relative 'item_container'
require 'json'
require 'csv'
require 'fileutils'

class Cart
  include ItemContainer
  attr_accessor :items

  def initialize
    @items = []
  end

  def count_items
    self.class.item_count(@items)
  end

  def save_to_file(file_path)
    File.open(file_path, 'w') do |file|
      items.each { |item| file.puts item.to_s }
    end
  end

  def save_to_json(file_path)
    File.open(file_path, 'w') do |file|
      file.puts(JSON.generate(items.map(&:to_h)))
    end
  end

  def save_to_csv(file_path)
    CSV.open(file_path, 'w') do |csv|
      csv << Item.new("", "", "", "", "", "").to_h.keys
      items.each { |item| csv << item.to_h.values }
    end
  end
end
