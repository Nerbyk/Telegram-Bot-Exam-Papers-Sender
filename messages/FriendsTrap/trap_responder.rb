# frozen_string_literal: true

class Ids
  VASYA  = 454_185_333
  KOLYA  = 540_872_572
  ASLAN  = 613_629_855
  DANON  = 574_915_418
  NIKITA = 476_503_801

  def get
    [VASYA, KOLYA, ASLAN, DANON, NIKITA]
  end
end

class TrapResponder
  attr_reader :bot, :message, :user_input, :client_id
  def call(bot:, message:, user_input:, db: nil)
    @bot         = bot
    @message     = message
    @user_input  = user_input
    @client_id   = message.from.id
    @db          = db
    respond(client_id)
  end

  def respond(client_id)
    case client_id
    when Ids::VASYA
      answer_vasya
    when Ids::KOLYA
      answer_kolya
    when Ids::ASLAN
      answer_aslan
    when Ids::DANON
      answer_danon
    when Ids::NIKITA
      answer_nikita
    end
  end

  def answer_vasya
    if user_input == '/start'
      bot.api.send_message(chat_id: client_id, text: 'Слышь ебать, дура тупая, еще раз я тебя')
      bot.api.send_message(chat_id: client_id, text: 'тут нахуй увижу')
      bot.api.send_message(chat_id: client_id, text: 'чепуха ебаная, ты будешь сосать')
      bot.api.send_message(chat_id: client_id, text: 'ты меня понял?')
    else
      bot.api.send_message(chat_id: client_id, text: 'съебался отсюда')
    end
  end

  def answer_kolya
    if user_input == '/start'
      bot.api.send_message(chat_id: client_id, text: 'КОЛЯ КОЛЯ ТРАХНИ МЕНЯ')
      bot.api.send_message(chat_id: client_id, text: 'КОЛЯ КОЛЯ ТРАХНИ МЕНЯ')
      bot.api.send_message(chat_id: client_id, text: 'КОЛЯ ТЫ МОЯ ВСЕЛЕННАЯ')
      bot.api.send_message(chat_id: client_id, text: 'Я НЕ МОГУ БЕЗ ТЕБЯ')
      bot.api.send_message(chat_id: client_id, text: 'Я ХОЧУ ТЕБЯ КОЛЯЯЯЯЯЯЯЯ')
    else
      bot.api.send_message(chat_id: client_id, text: 'Выйди отсюда, розбийник')
    end
  end

  def answer_aslan
    if user_input == '/start'
      bot.api.send_message(chat_id: client_id, text: 'Слышь, казах, ты че тут забыл?')
      bot.api.send_message(chat_id: client_id, text: 'Тебе проблем в жизни мало?')
      bot.api.send_message(chat_id: client_id, text: 'Я тебя щас порешаю сучара')
      bot.api.send_message(chat_id: client_id, text: 'Ублюдок мать твою(ебал) а ну иди сюда, вздумал ко мне лезть?')
      bot.api.send_message(chat_id: client_id, text: 'Ну давай, попробуй трахнуть меня, ДА Я ТЕБЯ САМ ТРАХНУ')
    else
      bot.api.send_message(chat_id: client_id, text: 'всё, давай, бывай, каках')
    end
  end

  def answer_danon
    if user_input == '/start'
      bot.api.send_message(chat_id: client_id, text: 'Я буду говрить только с яночкой')
      bot.api.send_message(chat_id: client_id, text: 'Она самая лучшая, она меня разбанила')
      bot.api.send_message(chat_id: client_id, text: 'спасибо ей, солнышку')
    else
      bot.api.send_message(chat_id: client_id, text: 'Я сказал, только с яночкой')
    end
  end

  def answer_nikita
    if user_input == '/start'
      bot.api.send_message(chat_id: client_id, text: 'Позови пожалуйста Дариночку или леночку...')
      bot.api.send_message(chat_id: client_id, text: 'Я так по ним соскучился, по моим бубочкам')
      bot.api.send_message(chat_id: client_id, text: 'эх... было время... были вместе, а теперь они там одни, бедняжки...')
    end
  end
end
