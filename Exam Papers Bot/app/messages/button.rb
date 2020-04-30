# frozen_string_literal: true

require './messages/actions/get_message_text.rb'
require './messages/request/get_user_info.rb'
class MessageButton < MessageResponder
  attr_reader :bot, :message, :my_text
  def call(bot:, message:)
    super
  end

  def respond(_client_id)
    if message.data == 'Start'
      edit_buttoned_text(my_text.reply('greeting_first_time_user'))
      get_user_info = GetUserInfo.new
      get_user_info.call(bot: bot, message: message)
    end
  end

  def edit_buttoned_text(text)
    EditMessage.new.call(bot: bot, chat: message.message.chat, message_id: message, text: text)
  end
end

class EditMessage
  def call(bot:, chat:, message_id:, text:)
    bot.api.edit_message_text(chat_id: chat.id, message_id: message_id.message.message_id, text: text)
  end
end
