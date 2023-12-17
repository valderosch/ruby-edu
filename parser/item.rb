class Item
  attr_accessor :title, :description, :location, :date, :company, :link

  def initialize(title, description, location, date, company, link)
    @title = title
    @description = description
    @location = location
    @date = date
    @company = company
    @link = link
  end

  def info(&block)
    block.call(self) if block_given?
  end

  def to_s
    "| #{title} | #{location} | #{company} | #{date} | #{description}) | #{link} |\n"
  end

  def to_h
    { title: @title, description: @description, location: @location, date: @date, company: @company, link: @link }
  end
end
