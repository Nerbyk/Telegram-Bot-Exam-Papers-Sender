
require 'sqlite3'
require 'telegram/bot'
require './config.rb' # file with bot token
include Config

# module for manipulations with sqlite3 , will be a class soon
module DataBase
  $db = SQLite3::Database.new "test.db"
  def self.make_record(user_id, user_name, vk_link, subject, status)
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

    $db.execute("select * from userdetails ") do |row|
      puts("id = #{id.to_s}, row[0] = #{row[0]}. row[4] = #{row[4]}")
      if row[0] == id.to_s && row[4] == 'accepted'
        puts("TRIGGERED")
        return false
      end
    end
    return true 
  end

  def self.showData
    $db.execute("select * from userdetails") do |row|
      p row
    end
  end

end

token = Config::TOKEN

Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
        case message
        when Telegram::Bot::Types::CallbackQuery
            case message.data
            when 'Name'
                bot.api.edit_message_text(chat_id: message.message.chat.id, message_id: message.message.message_id, text: "Привет, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогу тебе получить нужные билеты. Следуй моим инструкциям!" )
                bot.api.send_message(chat_id: message.from.id, text: "Введите своё Имя и Фамилию")
            end
        when Telegram::Bot::Types::Message
            case message.text
            when '/start'
              if DataBase.check_id(message.from.id)
              bot.api.send_message(chat_id: message.chat.id, text: "#{message.from.id}")
              bot.api.send_message(chat_id: message.chat.id, text: "#{DataBase.check_id(message.from.id.to_s)}")
              kb = Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Получить билеты!', callback_data: "Name")
              markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
              bot.api.send_message(chat_id: message.chat.id, text: "Привет, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогу тебе получить нужные билеты. Следуй моим инструкциям!", reply_markup: markup)
              # if a person already received examination papers from a bot
              else
              bot.api.send_message(chat_id: message.chat.id, text: "Приветствую, #{message.from.first_name}, я Бот от сообщества Pozor! Brno, я помогаю получать нужные билеты к нострификации. По моим данным ты уже получил билеты. Получить их можно лишь раз.\n\nСвяжись с моим создателем, если считаешь иначе @nerby1")
              end
            else
              bot.api.send_message(chat_id: message.chat.id, text: "Я не хочу работать, мой создатель ленивый уебан")
            end

        end
    end
end



# User id

# bot.api.send_message(chat_id: rqst.chat.id, text: "#{rqst.from.id}")
