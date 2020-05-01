# frozen_string_literal: true

require './messages/actions/get_message_text.rb'
require './messages/request/get_user_info.rb'
require './Database/database.rb'
require './messages/responder.rb'

class MessageButton < MessageResponder
  attr_reader :bot, :message, :user_input, :my_text
  def call(bot:, message:, user_input:)
    super
  end

  def respond(client_id)
    if message.data == 'Start'
      db = Database.new(id:client_id, status: 'registered').registrate
      edit_buttoned_text(my_text.reply('greeting_first_time_user'))
      puts("Start pressed")
      answer_with_message(my_text.reply('get_user_info_name'))
    end
  end

  def edit_buttoned_text(text)
    EditMessage.new.call(bot: bot, chat: message.message.chat, message_id: message, text: text)
  end

  def answer_with_message(text, reply_markup = nil)
    SendMessage.new.call(bot: bot, chat: message.message.chat, text: text, reply_markup: reply_markup)
  end
end

class EditMessage
  def call(bot:, chat:, message_id:, text:)
    bot.api.edit_message_text(chat_id: chat.id, message_id: message_id.message.message_id, text: text)
  end
end
