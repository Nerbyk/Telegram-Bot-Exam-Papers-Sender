# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './messages/responder.rb'
Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
    message_responder = MessageResponder.new
    message_responder.call(bot: bot, message: message)
  end
end
