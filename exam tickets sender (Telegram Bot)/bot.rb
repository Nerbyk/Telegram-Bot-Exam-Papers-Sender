# frozen_string_literal: true

# TODO: Привести в нормальный вид, а лучше переписать
require 'sqlite3'
require 'telegram/bot'
require './config.rb' # file with bot token
include Config

ADMIN_USER_ID = 143_845_427
# module for manipulations with sqlite3 , will be a class soon
module DataBase
  $db = SQLite3::Database.new 'test.db'
  def self.make_record(import_arr, status)
    user_id = import_arr[0]
    user_name = import_arr[1]
    vk_link = import_arr[2]
    subject = import_arr[3]
    status = status
    $db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS userdetails (
        user_id varchar(50),
        user_name varchar(50),
        vk_link varchar(50),
        subjects varchar(50),
        status varchar(50)
      );
    SQL

    $db.execute("INSERT INTO userdetails(user_id, user_name, vk_link, subjects, status)
                VALUES (?, ?, ?, ?, ?)", [user_id, user_name, vk_link, subject, status])
  end

  def self.check_id(id)
    $db.execute('select * from userdetails ') do |row|
      if row[0] == id.to_s && row[4] == 'accepted'
        return row[4]
      elsif row[0] == id.to_s && row[4] == 'in progress'
        return row[4]
      end
    end
    false
  end

  def self.showData
    $db.execute('select * from userdetails') do |row|
      p row
    end
  end
end

def start_msg(bot, message)
  # if DataBase.check_id(message.from.id)
  kb = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Получить билеты!', callback_data: 'Name')
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогу тебе получить нужные билеты. Следуй моим инструкциям!", reply_markup: markup)
  # else # if a person already received examination papers from a bot
  # bot.api.send_message(chat_id: message.chat.id, text: "Приветствую, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогаю получать нужные билеты к нострификации. По моим данным ты уже получил билеты. Получить их можно лишь раз.\n\nСвяжись с моим создателем, если считаешь иначе @nerby1")
  # end
end

def ask_name(bot, message)
  bot.api.edit_message_text(chat_id: message.message.chat.id, message_id: message.message.message_id, text: "Привет, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогу тебе получить нужные билеты. Следуй моим инструкциям!")
  bot.api.send_message(chat_id: message.from.id, text: 'Введите своё Имя и Фамилию')
end

def get_name(_bot, message)
  name = message.text if message.text != '/start'
  name
end

def get_vk_link(_bot, message)
  vk = message.text
end

def get_photo(bot)
  puts(bot.api.get_updates.dig('result', 0, 'message', 'photo', -1, 'file_id'))
  file_id = bot.api.get_updates.dig('result', 0, 'message', 'photo', -1, 'file_id')
  file_id
end

token = Config::TOKEN
import_arr = []
subjects = []
i = 0 # counter to track on which step user is and to prevent /start spam
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::CallbackQuery
      case message.data
      when 'Name'
        ask_name(bot, message)
      when 'Retry'
        bot.api.edit_message_caption(chat_id: message.message.chat.id, message_id: message.message.message_id, caption: 'Retrying...')
        i = 0
        bot.api.send_message(chat_id: message.from.id, text: 'Введите команду /start')
      when 'Send'
        bot.api.forward_message(chat_id: ADMIN_USER_ID, from_chat_id: message.message.chat.id, message_id: message.message.message_id)
        # reply = message.message.reply_to_message
        # if reply
        #   text = message.text
        #   bot.api.send_message(chat_id: reply.forward_from.id, text: text)
        # end

        bot.api.edit_message_caption(chat_id: message.message.chat.id, message_id: message.message.message_id, caption: 'Ваша заявка была отправлена на рассмотрение. Введите /status для проверки.')
        status = 'in progress'
        DataBase.make_record(import_arr, status)
      end
    when Telegram::Bot::Types::Message

      case message.text
      when '/start'
        i = 0 unless DataBase.check_id(message.from.id)
        i = -1 if DataBase.check_id(message.from.id) == 'accepted'
        i = -2 if DataBase.check_id(message.from.id) == 'in progress'
        if i == 0 # if first time started from this user
          import_arr << message.from.id.to_s
          start_msg(bot, message)
          i = 1
        elsif i > 1 # if already in using

        elsif i == -1 # if already received examination papers from a bot
          bot.api.send_message(chat_id: message.chat.id, text: "Приветствую, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогаю получать нужные билеты к нострификации. По моим данным ты уже получил билеты. Получить их можно лишь раз.\n\nСвяжись с моим создателем, если считаешь иначе @nerby1")
        elsif i == -2
          bot.api.send_message(chat_id: message.chat.id, text: 'Твоя заявка всё еще на рассмотрении, загляни ко мне чуть позже')
        end
      when '/status'
        if DataBase.check_id(message.from.id) == 'in progress'
          bot.api.send_message(chat_id: message.chat.id, text: 'Твоя заявка всё еще на рассмотрении, загляни ко мне чуть позже')
        end
      else
        if i == 1
          import_arr << get_name(bot, message)
          bot.api.send_message(chat_id: message.chat.id, text: 'Введите вашу ссылку ВК')
          i = 2
        elsif i == 2
          import_arr << get_vk_link(bot, message)
          question = 'Введите назначенные предметы, используя внутреннюю клавиатуру'
          answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w[Химия Биология], %w[История География], %w[Обществознание Физика], %w[Математика Английский], %w[Информатика Немецкий], 'Закончить Ввод'])
          bot.api.send_message(chat_id: message.chat.id, text: question, reply_markup: answers)
          i = 3
        elsif i == 3
          subjects << message.text
          if message.text == 'Закончить Ввод'
            subjects.delete('Закончить Ввод')
            kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
            import_arr << subjects.join('; ')
            bot.api.send_message(chat_id: message.chat.id, text: 'Отправте фотографию документа из министерства', reply_markup: kb)
            i = 4
          end

        elsif i == 4
          file_id = get_photo(bot)
          bot.api.send_message(chat_id: message.chat.id, text: 'Вы ввели следующие данны:')
          kb = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Отправить заявку', callback_data: 'Send'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Заполнить заного', callback_data: 'Retry')
          ]
          markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
          bot.api.send_photo(chat_id: message.chat.id, photo: file_id, caption: "Ваше имя: #{import_arr[1]}\nСсылка вк: #{import_arr[2]}\nСписок предметов: #{import_arr[3]}", reply_markup: markup)

          i = 5
        elsif i == 5

        else
          bot.api.send_message(chat_id: message.chat.id, text: "Я не хочу работать, мой создатель ленивый ******* #{i}")
       end
      end

    end
  end
end

# User id

# bot.api.send_message(chat_id: rqst.chat.id, text: "#{rqst.from.id}")
