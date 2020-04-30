require './messages/get_message_text.rb'

class MessageButton < MessageResponder
  attr_reader :bot, :message, :my_text
  def call(bot:, message:)
    super
  end

  def respond(client_id)
    if message.data == 'Start'
      edit_buttoned_text(my_text.reply('greeting_first_time_user'))
      puts "KNOPKA BLIAT'"
    end
  end

  def edit_buttoned_text(text)
    EditMessage.new.call(bot: bot, chat: message, message_id: message, text: text)
  end

end

class EditMessage
  def call(bot:, chat:, message_id:, text:)
    bot.api.edit_message_text(chat_id: message.from.id, message_id: message.message.message_id, text: text)
  end
end
