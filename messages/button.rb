# frozen_string_literal: true

require './messages/actions/get_message_text.rb'
require './messages/responder.rb'

class MessageButton < MessageResponder
  attr_reader :bot, :message, :user_input, :my_text, :db
  def call(bot:, message:, user_input:, db:)
    super
  end

  def respond(client_id)
    if message.data == 'Start'
      db.call(id: client_id, status: 'registered', user_name: message.from.username)
      db.registrate
      edit_buttoned_text
      answer_with_message(my_text.reply('get_user_info_name'))
    elsif message.data == 'Send'
      answer_with_message(my_text.reply('request_sent'))
      db.call(id: client_id, status: 'in progress')
      db.update_data
      edit_buttoned_text
    elsif message.data == 'Retry'
      answer_with_message(my_text.reply('request_retry'))
      db.call(id: client_id)
      db.delete_user_progress
      edit_buttoned_text
    end
  end

  def edit_buttoned_text
    EditMarkup.new.call(bot: bot, chat: client_id, message_id: message)
  end

  def answer_with_message(text, reply_markup = nil)
    SendMessage.new.call(bot: bot, chat: client_id, text: text, reply_markup: reply_markup)
  end
end

class EditMarkup
  def call(bot:, chat:, message_id:)
    bot.api.edit_message_reply_markup(chat_id: chat, message_id: message_id.message.message_id)
  end
end
