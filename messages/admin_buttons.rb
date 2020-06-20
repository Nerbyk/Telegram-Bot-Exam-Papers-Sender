# frozen_string_literal: true

require './messages/admin_responder.rb'
require './messages/files_to_send/send_files.rb'

class AdminButton < AdminResponder
  attr_reader :bot, :message, :user_input, :my_text, :client_id, :db
  def call(bot:, message:, user_input:, db:)
    super
  end

  def respond(_client_id)
    case message.data
    when 'Accept'
      edit_buttoned_text
      request = db.admin_get_request
      subjects = request[:subjects]
      user_id = request[:user_id].to_i
      answer_to_client(user_id, my_text.reply('inpect_accept_message_to_user'))
      SendFiles.new(bot, user_id, subjects)
      db.call(id: user_id.to_s, status: Status::ACCEPTED)
      db.update_data
      inspect_requests
    when 'Deny'
      edit_buttoned_text
      request = db.admin_get_request
      user_id = request[:user_id].to_i
     # answer_with_message('Введите причину отказа')
     # reason = deny_msg
      answer_to_client(user_id, my_text.reply('inspect_deny_message_to_user'))
     # answer_to_client(user_id, reason)
      db.call(id: user_id.to_s)
      db.delete_user_progress
      inspect_requests
    when 'Ban'
      edit_buttoned_text
      request = db.admin_get_request
      user_id = request[:user_id].to_i
      answer_to_client(user_id, my_text.reply('insepct_ban_message_to_user'))
      db.call(id: user_id.to_s, status: Status::BAN)
      db.update_data
      inspect_requests
    when 'Menu'
      answer_menu
    end
  end

  def edit_buttoned_text
    EditMarkup.new.call(bot: bot, chat: client_id, message_id: message)
  end
  
  # def deny_msg
  #  bot.listen do |message|
  #   return message.text if message.text
  #  end
  # end
  
end

class EditMarkup
  def call(bot:, chat:, message_id:)
    bot.api.edit_message_reply_markup(chat_id: chat, message_id: message_id.message.message_id)
  end
end
