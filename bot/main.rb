require 'telegram/bot'

token = token

Telegram::Bot::Client.run(token) do |bot|
  Signal.trap('INT') do
    bot.stop
  end

  # keyboard
  def main_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Events' }],
        [{ text: 'Jobs' }],
        [{ text: 'Menu' }]
      ],
      one_time_keyboard: true
    )
  end

  def jobs_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'GetAll' }],
        [{ text: 'Back' }]
      ],
      one_time_keyboard: true
    )
  end

  def back_to_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Back to Menu' }],
        [{ text: 'Send File' }]
      ],
      one_time_keyboard: true
    )
  end

  def menu_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Back' }],
        [{ text: 'Account' }, { text: 'Settings' }]
      ],
      one_time_keyboard: true
    )
  end

  def display_jobs(bot, chat_id, page, message_id = nil)
    data_path = File.join(File.dirname(__FILE__), '..', 'out', 'data')
    jobs_data = load_data(data_path)

    group = jobs_data.each_slice(10).to_a[page - 1] || []
    message_text = ''

    group.each do |job|
      message_text += job_to_message(job) + "\n"
    end

    reply_markup = pagination_inline_keyboard(page, (jobs_data.size / 10.to_f).ceil)

    if message_id
      bot.api.edit_message_text(
        chat_id: chat_id,
        message_id: message_id,
        text: message_text,
        reply_markup: reply_markup
      )
    else
      bot.api.send_message(
        chat_id: chat_id,
        text: message_text,
        reply_markup: reply_markup,
        parse_mode: 'HTML'
      )
    end
  end

  current_page = 1

  def pagination_inline_keyboard(current_page, total_pages)
    buttons = [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Main Menu', callback_data: 'back_to_menu'),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'File', callback_data: 'send_file')
    ]

    inline_keyboard = [buttons]
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: inline_keyboard,
      one_time_keyboard: true
    )
  end

  def job_to_message(job)
    <<~MESSAGE
      <b>#{job['title']}</b>
      #jobs
      #{job['location']} | #{job['date']}
      <a href="#{job['link']}">Детальніше</a>
    MESSAGE
  end

  def load_data(data_path)
    files = Dir.glob(File.join(data_path, 'dou_*.json'))
    latest_file = files.max_by { |f| File.mtime(f) }
    return [] if latest_file.nil?
    JSON.parse(File.read(latest_file))
  end

  def send_doc_file(bot, chat_id)
    doc_path = File.join(File.dirname(__FILE__), 'dou_data.txt')

    bot.api.send_document(
      chat_id: chat_id,
      document: Faraday::UploadIO.new(doc_path, 'application/msword'),
      caption: 'Here is your DOC file.'
    )
  end

  current_page = 1

  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Hello, #{message.from.first_name}. I can find some events. Do you want to?",
        reply_markup: main_menu_keyboard
      )
    when 'Jobs'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Choose an option:",
        reply_markup: jobs_menu_keyboard
      )
    when 'Events'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, but I can't find any event for you",
        reply_markup: main_menu_keyboard
      )
    when 'Menu'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Choose an option:",
        reply_markup: menu_menu_keyboard
      )
    when 'GetAll'
      display_jobs(bot, message.chat.id, current_page)
    when 'Back'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: 'Going back to the main menu',
        reply_markup: main_menu_keyboard
      )
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name} 👋")
    when Telegram::Bot::Types::CallbackQuery
      case message.data
      when 'next'
        current_page += 1 if current_page < total_pages
      when 'prev'
        current_page -= 1 if current_page > 1
      when 'back_to_menu'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Going back to the main menu',
          reply_markup: main_menu_keyboard
        )
      when 'send_file'
        send_doc_file(bot, message.chat.id)
      end
      display_jobs(bot, message.chat.id, current_page)

      bot.api.send_message(
        chat_id: message.from.id,
        text: 'Choose an option:',
        reply_markup: back_to_menu_keyboard
      )
    end
  end
end