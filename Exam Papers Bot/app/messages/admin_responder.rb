# frozen_string_literal: true

require './messages/actions/get_message_text.rb'
require './messages/actions/inline_markup.rb'
require './messages/responder.rb'
require './Database/database.rb'
require './messages/status_constants.rb'

class AdminResponder < MessageResponder
  attr_reader :bot, :message, :user_input, :my_text, :client_id
  def call(bot:, message:, user_input:)
    @bot          = bot
    @message      = message
    @user_input   = user_input
    @client_id    = message.from.id
    @my_text      = GetMessageText.new(client: 'admin')
    respond(client_id)
  end

  def respond(_client_id)
    case user_input
    when '/start'
      answer_menu
    when '/inspect'
      inspect_requests
    when '/amount'
      get_amount_of_uninspected
    end
  end

  def answer_menu
    answer_with_message(my_text.reply('greeting_menu'))
  end

  def inspect_requests
    markup = MakeInlineMarkup.new(%w[Одобрить Accept], %w[Отказать Deny], %w[Забанить Ban], ['Вернуться в Главное меню', 'Menu']).get_markup
    request = Database.new.admin_get_request
    user_name = ''
    p request
    if !request
      answer_with_message('Нет новых заявок')
      answer_menu
    else
      request[:user_name].nil? ? user_name = 'N/A' : user_name = '@' + request[:user_name]
      if request[:status] == Status::INSPECTING && request[:status] != []
        answer_with_message(my_text.reply('not_ended_inspection'))
        send_photo("Имя Фамили: #{request[:name]}\nПредметы:#{request[:subjects]}\nTelegram:#{user_name}\nСсылка на ВК: #{request[:link]}", request[:image], markup)
      elsif request[:status] == Status::IN_PROGRESS && request[:status] != []
        send_photo("Имя Фамили: #{request[:name]}\nПредметы:#{request[:subjects]}\nTelegram:#{user_name}\nСсылка на ВК: #{request[:link]}", request[:image], markup)
      end
    end
  end

  def get_amount_of_uninspected
    amount = Database.new.get_number
    answer_with_message(my_text.reply('amount_message') + amount.to_s)
    answer_menu
  end

  def answer_to_client(chat_id, text, reply_markup = nil)
    SendMessage.new.call(bot: bot, chat: chat_id, text: text, reply_markup: reply_markup)
  end
end
