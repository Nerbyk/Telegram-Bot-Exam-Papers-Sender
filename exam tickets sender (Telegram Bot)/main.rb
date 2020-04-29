# frozen_string_literal: true

require 'sqlite3'
require 'telegram/bot'
require './config.rb' # file with bot token
require 'logger'
include Config
# error loging for rescue parsing
prs_log = Logger.new('prs_error.log', 'monthly')
# error loging for rescue api
api_log = Logger.new('api_error.log', 'monthly')
$import_arr = [] # array which will be passed to SQL
# class for manipulations with SQLite3
class DataBase
  @@db = SQLite3::Database.new 'test.db'
  attr_reader :id, :import_arr, :status
  def initialize(id: nil, status: nil) # default values
    @id         = id
    @status     = status
  end

  def make_record
    user_id   = $import_arr[0]
    user_name = $import_arr[1]
    vk_link   = $import_arr[2]
    subject   = $import_arr[3]
    image     = $import_arr[4]
    @@db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS userdetails (
        user_id varchar(50),
        user_name varchar(50),
        vk_link varchar(50),
        subjects varchar(50),
        image blob,
        status varchar(50)
      );
    SQL

    @@db.execute("INSERT INTO userdetails(user_id, user_name, vk_link, subjects,image, status)
                VALUES (?, ?, ?, ?, ?, ?)", [user_id, user_name, vk_link, subject, image, status])
  end

  def check_id
    @@db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS userdetails (
        user_id varchar(50),
        user_name varchar(50),
        vk_link varchar(50),
        subjects varchar(50),
        image blob,
        status varchar(50)
      );
    SQL

    @@db.execute('select * from userdetails ') do |row|
      return 'accepted' if row[0] == id.to_s && row[5] == 'accepted'
      return 'in progress' if row[0] == id.to_s && row[5] == 'in progress'
    end
    # if no matches => no data in DB => user's first time use => retruns false
    false
  end
end

class MakeInlineMsg
  def initialize(*inline_items)
    @inline_items = inline_items
  end

  def get_markup
    kb = []
    markup = []
    (0..@inline_items.length - 1).each do |i|
      kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: (@inline_items[i][0]).to_s, callback_data: (@inline_items[i][1]).to_s)
    end
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  end

  def get_link
    kb = []
    markup = []
    (0..@inline_items.length - 1).each do |i|
      kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: (@inline_items[i][0]).to_s, url: (@inline_items[i][1]).to_s)
    end

    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  end
end
# TODO: Make functionality for Admin|Developer
def for_admin(bot)
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: 'Привет, Dashka! К сожалению функционал для тебя всё еще в разработке, загляни позже!')
    end
  end
end

def start_msg(bot, message)
  markup = MakeInlineMsg.new(['Получить Билеты!', 'Start']).get_markup
  bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогу тебе получить нужные билеты. Следуй моим инструкциям!", reply_markup: markup)
end

def start_in_prog_msg(bot, message)
  bot.api.send_message(chat_id: message.chat.id, text: 'Твоя заявка находится всё еще на рассмотрении, используй команду /status для получения подробной информации')
end

def start_accepted_msg(bot, message)
  bot.api.send_message(chat_id: message.chat.id, text: "По моим данным ты же получил от меня билеты! Если ты не согласен - отпиши моему создателю\n\n@nerby1")
end

module UserInfo
  def self.get(bot, _client_id)
    i = 0 # counter for steps
    import_arr = []
    name, vk_link, photo, status = ''
    subjects = []
    puts('POSOSI LOSHARA')
    bot.listen do |message|
      case message.text
      when message.text
        case i
        when 0 # first step - get users name and surname
          puts('NAME STEP')
          name = message.text
          if check_name(name)
            i = 1
            bot.api.send_message(chat_id: $client_id, text: 'Введите вашу ссылку ВК')
          else
            bot.api.send_message(chat_id: $client_id, text: "Неправильный ввод. Введите данные в Формтае:\nИмя Фамилия")
          end
        when 1 # second step - get user's VKontakte link
          puts("VK STEP, name = #{name}")
          vk_link = message.text
          if check_membership(vk_link)
            i = 2
            markup = make_subjects
            bot.api.send_message(chat_id: $client_id, text: 'Введите назначенные предметы при помощи клавиатуры, которая вылезет снизу.', reply_markup: markup)
          else
            # membership = [
            #   Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Группа ВК', url: 'https://vk.com/pozor.brno'),
            #   Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Telegram Канал', url: 'https://t.me/pozor_brno')
            # ]
            # markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: membership)
            membership = MakeInlineMsg.new(['Группа ВК', 'https://vk.com/pozor.brno'], ['Telegram Канал', 'https://t.me/pozor_brno']).get_link
            bot.api.send_message(chat_id: $client_id, text: 'Пожалуйста, проверьте наличие подписок по кнопкам ниже и повторите попытку ввода', reply_markup: membership)
            bot.api.send_message(chat_id: $client_id, text: 'Введите повторно ссылку на ВК')

          end
        when 2 # third step = get examination subjects
          puts("vk = #{vk_link}, name = #{name}")
          subjects << message.text unless check_each_subject(message.text, bot)
          if message.text == 'Закончить Ввод'
            subjects.delete('Закончить Ввод')
            if !check_all_subjects(subjects, bot)
              remove_markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
              i = 3
              bot.api.send_message(chat_id: message.chat.id, text: 'Отправте фотографию документа из министерства', reply_markup: remove_markup)
            elsif check_all_subjects(subjects, bot) == 'to much'
              bot.api.send_message(chat_id: message.chat.id, text: 'Вы ввели слишком много предметов. Введите предметы заного.')
              subjects = []
            elsif check_all_subjects(subjects, bot) == 'matches'
              bot.api.send_message(chat_id: message.chat.id, text: 'Вы ввели один предмет несколько раз. Введите предметы заного.')
              subjects = []
            end
          end
        when 3 # fourth step - get photo from ministry
          photo = bot.api.get_updates.dig('result', 0, 'message', 'photo', -1, 'file_id')
          p photo
          import_arr = [$client_id, name, vk_link, subjects.join(';'), photo]
          return import_arr

        end
      end
    end
  end

  def self.check_name(name)
    return false if name.length > 50
    if name.split(' ').length > 2
      return false
    end # if more, than 2 strings were passed
    return false if name.split.length == 1

    true
  end

  def self.check_membership(vk_link)
    # TODO: Parse VK group members and Telegram members
    vk_link != 'false'
  end

  def self.make_subjects
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w[История Физика Химия], %w[Информатика Биология], %w[Обществознание География], %w[Математика Английский], 'Закончить Ввод'])
  end

  def self.check_each_subject(message, bot)
    available_list = ['Биология', 'География', 'Химия', 'Информатика', 'Английский', 'История', 'Физика', 'Закончить Ввод']
    if available_list.include?(message)
      false
    else
      unless available_list.include?(message)
        bot.api.send_message(chat_id: $client_id, text: 'Пожалуйста используйте кливиатуру снизу для ввода предметов.')
      end
      true
    end
  end

  def self.check_all_subjects(subjects, _bot)
    return 'to much' if subjects.length > 6
    return 'matches' if subjects.length > subjects.uniq.length

    false
  end
end

# loop do
#  begin
Telegram::Bot::Client.run(Config::TOKEN) do |bot|
  bot.listen do |message|
    $client_id = message.from.id # user_id

    #  Thread.start(message) do |message|
    #  for_admin(bot) if message.from.id == Config::ADMIN_ID
    case message
    when Telegram::Bot::Types::CallbackQuery # inline buttons
      case message.data
      when 'Start'

        bot.api.edit_message_text(chat_id: message.message.chat.id, message_id: message.message.message_id, text: "Привет, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогу тебе получить нужные билеты. Следуй моим инструкциям!")
        bot.api.send_message(chat_id: $client_id, text: 'Введите ваше Имя и Фмилию')
        $import_arr = UserInfo.get(bot, $client_id)
        markup = MakeInlineMsg.new(['Отправить заявку', 'Send'], ['Заполнить заного', 'Retry']).get_markup
        bot.api.send_photo(chat_id: $client_id, photo: $import_arr[4], caption: "Ваше имя: #{$import_arr[1]}\nСсылка вк: #{$import_arr[2]}\nСписок предметов: #{$import_arr[3]}", reply_markup: markup)
      when 'Send'
        DataBase.new(status: 'in progress').make_record
        bot.api.send_message(chat_id: $client_id, text: 'Ваша заявка была отправлена. Для проверки введите /status')
      when 'Retry'
        bot.api.send_message(chat_id: $client_id, text: 'Введите команду /start для заполнения заявки для получения билетов для нострификации')
        end
    when Telegram::Bot::Types::Message
      case message.text
      when '/start'
        start_msg(bot, message) unless DataBase.new(id: $client_id).check_id
        if DataBase.new(id: $client_id).check_id == 'in progress'
          start_in_prog_msg(bot, message)
      end
        if DataBase.new(id: $client_id).check_id == 'accepted'
          start_accepted_msg(bot, message)
      end
        end
      end
    #  rescue Exception => e
    # prs_log.error "Error = #{e}"
    # puts "For detailed error messages, see the file: /temp/error.log"
    # end
  end
  # end
end
#  rescue Exception => e
# api_log.error "Error = #{e}"
# puts "For detailed error messages, see the file: /temp/error.log"
#  end
# end
