# frozen_string_literal: true

require './messages/actions/verification.rb'
require './messages/actions/get_message_text.rb'
require './messages/actions/inline_markup.rb'
require './messages/request_methods.rb'
require './messages/actions/check_input.rb'
require './Database/database.rb'
require 'dotenv'
Dotenv.load('./.env') # to get admin user_id

class MessageResponder
  attr_reader :bot, :message, :user_input, :my_text, :client_id, :verification, :import_info
  include RequestMethods
  def call(bot:, message:, user_input:)
    @bot          = bot
    @message      = message
    @user_input   = user_input
    @my_text      = GetMessageText.new
    @client_id    = message.from.id
    @verification = Verification.new.call(client_id: client_id)
    respond(client_id)
  end

  def respond(client_id)
    #  if client_id != ENV['ADMIN_ID'] # if user not admin
    if user_input == '/start'
      answer_with_greeting_message unless verification
      answer_with_in_progress_notification if verification == 'in progress'
      answer_with_accepted_notification if verification == 'accepted'
    end
    case verification
    when 'registered'
      get_name
    when 'name'
      get_link
    when 'link'
      get_subjects
    when 'subjects'
      get_photo
    when 'photo'
      show_request
    end
    #  end
  end

  def answer_with_greeting_message
    markup = MakeInlineMarkup.new(['Получить Билеты!', 'Start']).get_markup
    answer_with_message(my_text.reply('greeting_first_time_user'), markup)
  end

  def answer_with_in_progress_notification
    answer_with_message(my_text.reply('greeting_in_progress_user'))
  end

  def answer_with_accepted_notification
    answer_with_message(my_text.reply('greeting_accepted_user'))
  end

  def answer_with_message(text, reply_markup = nil)
    SendMessage.new.call(bot: bot, chat: message.chat, text: text, reply_markup: reply_markup)
  end

  def send_photo(caption, photo, reply_markup)
    SendPhoto.new.call(bot: bot, chat: message.chat,photo: photo, caption: caption, reply_markup: reply_markup)
  end
end

class SendMessage
  def call(bot:, chat:, text:, reply_markup:)
    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: reply_markup)
  end
end

class SendPhoto
  def call(bot:, chat:, photo:, caption:, reply_markup:)
    bot.api.send_photo(chat_id: chat.id, photo: photo, caption: caption, reply_markup: reply_markup)
  end
end