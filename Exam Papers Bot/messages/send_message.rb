# frozen_string_literal: true

class SendMessage
  def call(bot:, chat:, text:, reply_markup:)
    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: reply_markup)
  end
end
