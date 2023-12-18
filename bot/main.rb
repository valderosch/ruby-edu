require 'telegram/bot'

token = '6833964421:AAFeNeVesiWNDsxEptHf7CJa5WZwbykkhAk'

# Bot initiation
Telegram::Bot::Client.run(token) do |bot|
  Signal.trap('INT') do
    bot.stop
  end

  # keyboard
  def main_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Events' }, { text: 'Jobs' }],
        [{ text: 'Menu' }]
      ],
      one_time_keyboard: true
    )
  end

  def jobs_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'All' }, { text: 'Latest' }],
        [{ text: 'Back' }]
      ],
      one_time_keyboard: true
    )
  end

  def back_to_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Back to Menu' }, { text: 'Send File' }]
      ],
      one_time_keyboard: true
    )
  end

  def menu_menu_keyboard
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [{ text: 'Account' }, { text: 'Settings' }, {text: 'Help'}],
        [{ text: 'Back' }]
      ],
      one_time_keyboard: true
    )
  end

  def pagination_inline_keyboard(current_page, total_pages)
    buttons = [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Back'),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'File', callback_data: 'send_file')
    ]

    inline_keyboard = [buttons]
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: inline_keyboard,
      one_time_keyboard: true
    )
  end

  def display_jobs(bot, chat_id, page, message_id = nil, data_path)
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

  # Message structure
  def job_to_message(job)
    <<~MESSAGE
      <b>#{job['title']}</b>
      #jobs
      <b>#{job['location']}</b> | #{job['date']}
      <a href="#{job['link']}">Детальніше</a>
    MESSAGE
  end

  # Load data from file
  def load_data(data_path)
    files = Dir.glob(File.join(data_path, 'dou_*.json'))
    latest_file = files.max_by { |f| File.mtime(f) }
    return [] if latest_file.nil?
    JSON.parse(File.read(latest_file))
  end

  # Send message to user
  def send_file(bot, chat_id, data_path)
    files = Dir.glob(File.join(data_path, '*.txt'))
    latest_file = files.max_by { |f| File.mtime(f) }

    if latest_file
      bot.api.send_document(
        chat_id: chat_id,
        document: Faraday::UploadIO.new(latest_file, 'text/plain'),
        caption: 'Here is all info in file.'
      )
    else
      bot.api.send_message(chat_id: chat_id, text: 'No TXT files found.')
    end
  end

  current_page = 1
  data_path = File.join(File.dirname(__FILE__), '..', 'out', 'data')
  # Event Listener
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Hello, #{message.from.first_name}. I can find some events. Do you want to? Push the buttons",
        reply_markup: main_menu_keyboard
      )
    when 'Jobs'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Choose what do you want to find \n💬 All vacancies \n🔥 Latest and hot",
        reply_markup: jobs_menu_keyboard
      )
    when 'Events'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, but і can't find any event for you",
        reply_markup: main_menu_keyboard
      )
    when 'Menu'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Choose an option:",
        reply_markup: menu_menu_keyboard
      )
    when 'All'
      display_jobs(bot, message.chat.id, current_page, data_path)
    when 'File'
      send_file(bot, message.chat.id, data_path)
    when 'Back'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: 'Going back to the main menu',
        reply_markup: main_menu_keyboard
      )
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name} 👋")

      # Callback buttons handler
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
      end
      display_jobs(bot, message.chat.id, current_page, data_path)

      bot.api.send_message(
        chat_id: message.from.id,
        text: 'Choose an option:',
        reply_markup: back_to_menu_keyboard
      )
    end
  end
end