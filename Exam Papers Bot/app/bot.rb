# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require 'logger'
require './messages/responder.rb'
require './messages/button.rb'
require './messages/admin_responder.rb'
require './messages/admin_buttons.rb'
Dotenv.load('./.env')
prs_log = Logger.new('prs_error.log', 'monthly')
Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
    begin
     case message
     when Telegram::Bot::Types::CallbackQuery
      if message.from.id.to_s != ENV['ADMIN_ID']
        message_button = MessageButton.new
      else
        message_button = AdminButton.new
      end
       message_button.call(bot: bot, message: message, user_input: nil)
     else
      if message.from.id.to_s != ENV['ADMIN_ID']
      message_responder = MessageResponder.new
      else
      message_responder = AdminResponder.new
      end
      message_responder.call(bot: bot, message: message, user_input: message.text)
     end
    rescue Exception => e
      bot.api.send_message(chat_id: message.from.id, text: 'Пожалуйста введите данные требуемого формата.')
      prs_log.error "User_id #{message.from.id}, User name = #{message.from.username} Error = #{e}"
      puts("User_id #{message.from.id}, User name = #{message.from.username} Error = #{e}")
    end
  end
end
