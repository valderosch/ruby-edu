require 'telegram/bot'
require_relative 'settings'

token = api_token

Telegram::Bot::Client.run(token) do |bot|

  Signal.trap('INT') do
    bot.stop
  end

  bot.listen do |message|
    case message.text
      when '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}.
I can find some events. Do you want to?\n
Use this commands to navigate through:\n
/events - to find actual events\n
/jobs -  to find actual jobs")
      when '/jobs'
      bot.api.send_message(chat_id: message.chat.id, text: "Sorry, but i cant find any event for you for you")
      when '/events'
      bot.api.send_message(chat_id: message.chat.id, text: "Sorry, but i cant find any job for you")
      when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      end
    end
end

