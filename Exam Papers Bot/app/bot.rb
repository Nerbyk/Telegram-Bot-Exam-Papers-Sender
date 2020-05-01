# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './messages/responder.rb'
require './messages/button.rb'
Dotenv.load('./.env')



Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
     begin
      case message
      when Telegram::Bot::Types::CallbackQuery
        message_button = MessageButton.new
        message_button.call(bot: bot, message: message, user_input: nil)
      else
        message_responder = MessageResponder.new
        message_responder.call(bot: bot, message: message, user_input: message.text)
      end
    rescue Exception => e
      bot.api.send_message(chat_id: message.from.id, text: "Пожалуйста введите данные требуемого формата.")
      p e
    end
  end
end
