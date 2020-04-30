# frozen_string_literal: true

require './messages/send_message.rb'
require './messages/verification.rb'
require './messages/get_message_text.rb'
require './messages/inline_markup.rb'
require 'dotenv'
require 'yaml'
Dotenv.load('./.env') # to get admin user_id

class MessageResponder
  attr_reader :bot, :message, :text
  def call(bot:, message:)
    @bot     = bot
    @message = message
    @text    = GetMessageText.new
    respond(message.from.id)
  end

  def respond(client_id)
    #  if client_id != ENV['ADMIN_ID'] # if user not admin
        start_check = Verification.new.call(client_id: client_id)
        answer_with_greeting_message if !start_check
        answer_with_in_progress_notification if start_check == 'in progress'
        answer_with_accepted_notification if start_check == 'accepted'
    #  end
  end

  def answer_with_greeting_message
    markup = MakeInlineMarkup.new(['Получить Билеты!', 'Start']).get_markup
    answer_with_message(text.reply("greeting_first_time_user"), markup)
  end

  def answer_with_in_progress_notification
    answer_with_message(text.reply("greeting_in_progress_user"))
  end

  def answer_with_accepted_notification
    answer_with_message(text.reply("greeting_accepted_user"))
  end

  def answer_with_message(text, reply_markup = nil)
    SendMessage.new.call(bot: bot, chat: message.chat, text: text, reply_markup: reply_markup)
  end
end