# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './app/messages/responder.rb'
require './app/messages/button.rb'
Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
      message_responder = MessageResponder.new
      message_responder.call(bot: bot, message: message)
    when Telegram::Bot::Types::CallbackQuery
      message_button = MessageButton.new
      message_button.call(bot: bot, message: message)
    end
  end
end
