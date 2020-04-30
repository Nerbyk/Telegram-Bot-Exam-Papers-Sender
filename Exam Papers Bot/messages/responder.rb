# frozen_string_literal: true

require './messages/send_message.rb'
require 'dotenv'
Dotenv.load('./.env') # to get admin user_id

class MessageResponder
  attr_reader :bot, :message
  def call(bot:, message:)
    @bot     = bot
    @message = message
    respond(message.from.id)
  end

  def respond(client_id)
      if client_id != ENV['ADMIN_ID'] # if user not admin

      end
  end

  def answer_with_greeting_message
    answer_with_message("Hello")
  end

  def answer_with_message(text)
    SendMessage.new.call(bot: bot, chat: message.chat, text: text)
  end
end
