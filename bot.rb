# frozen_string_literal: true

require 'dotenv'
require 'logger'
require './messages/responder.rb'
require './messages/button.rb'
require './messages/admin_responder.rb'
require './messages/admin_buttons.rb'
require './db/db.rb'
require 'telegram/bot'
Dotenv.load('./.env')

db = Database.new
prs_log = Logger.new('prs_error.log', 'monthly')
user_log = Logger.new('user_input.log', 'monthly')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
    begin
         case message
         when Telegram::Bot::Types::CallbackQuery
           message_button = if message.from.id.to_s != ENV['ADMIN_ID']
                              MessageButton.new
                            else
                              AdminButton.new
                            end
           message_button.call(bot: bot, message: message, user_input: nil, db: db)
         else
           message_responder = if message.from.id.to_s == ENV['ADMIN_ID']
                                 AdminResponder.new
                               else
                                 MessageResponder.new
                               end
           message_responder.call(bot: bot, message: message, user_input: message.text, db: db)
           user_log.debug("User id = #{message.from.id} User name = #{message.from.username}, message = #{message.text}")
         end
    rescue StandardError => e
      bot.api.send_message(chat_id: message.from.id, text: "Пожалуйста введите данные требуемого формата.\n\nПри возникновении трудностей писать сюда - @nerby1")
      prs_log.error "User_id #{message.from.id}, User name = #{message.from.username} Error = #{e}"
      p e
       end
  end
end
