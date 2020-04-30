# frozen_string_literal: true

class SendMessage
  def call(bot:, chat:, text:)
    bot.api.send_message(chat_id: chat.id, text: text)
  end
end
