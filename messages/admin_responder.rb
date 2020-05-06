# frozen_string_literal: true

require './messages/actions/get_message_text.rb'
require './messages/actions/inline_markup.rb'
require './messages/responder.rb'
require './messages/status_constants.rb'

class AdminResponder < MessageResponder
  attr_reader :bot, :message, :user_input, :my_text, :client_id, :db
  def call(bot:, message:, user_input:, db:)
    @bot          = bot
    @message      = message
    @user_input   = user_input
    @client_id    = message.from.id
    @my_text      = GetMessageText.new(client: 'admin')
    @db           = db
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
    else
      bot.api.send_message(chat_id: message.from.id, text: message.message_id.to_s)
    end
  end

  def answer_menu
    answer_with_message(my_text.reply('greeting_menu'))
  end

  def inspect_requests
    request = db.admin_get_request
    markup = MakeInlineMarkup.new(%w[Одобрить Accept], %w[Отказать Deny], %w[Забанить Ban], ['Вернуться в Главное меню', 'Menu']).get_markup

    # return unless request[:status] != []

    if !request
      answer_with_message('Нет новых заявок')
      answer_menu
    else
      user_name = if request[:user_name].nil?
                    'N/A'
                  else
                    "@#{request[:user_name]}"
      end

      is_inspecting = request[:status] == Status::INSPECTING
      is_inprogress = request[:status] == Status::IN_PROGRESS

      if is_inspecting
        answer_with_message(my_text.reply('not_ended_inspection'))
      end

      if is_inspecting || is_inprogress
        send_photo("Имя Фамили: #{
          request[:name]
        }\nПредметы:#{
          request[:subjects]
        }\nTelegram:#{
          user_name
        }\nСсылка на ВК: #{
          request[:link]
        }",
                   request[:image],
                   markup)
      end

    end
  end

  def get_amount_of_uninspected
    amount = db.get_number
    answer_with_message(my_text.reply('amount_message') + amount.to_s)
    answer_menu
  end

  def answer_to_client(chat_id, text, reply_markup = nil)
    SendMessage.new.call(bot: bot, chat: chat_id, text: text, reply_markup: reply_markup)
  end
end
