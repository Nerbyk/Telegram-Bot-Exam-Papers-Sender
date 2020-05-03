# frozen_string_literal: true

class SendFiles
  attr_reader :bot, :id, :subjects

  def initialize(bot, id, subjects)
    @bot        = bot
    @id         = id
    @subjects   = subjects
    send
  end

  def send
    file_ids = FileId.new.get_ids
    subjects.split(' ').each do |subject|
      send_one_file(file_ids[subject])
    end
  end

  def send_one_file(document)
    SendFile.new.call(bot: bot, chat: id, document: document)
  end
end

class SendFile
  def call(bot:, chat:, document:)
    bot.api.send_document(chat_id: chat, document: document)
  end
end

class FileId
  BIO = 'BQACAgIAAxkBAAIQ4V6ujZGRp2lY23A7gxbSdfZ-5G_cAAK_BQAC5jhxSXeByt14gt74GQQ'
  GEO = 'BQACAgIAAxkBAAIQ216ujUFj97nzcZorV6tmsphVTN4FAAK8BQAC5jhxSW8BzsvJ0MY1GQQ'
  CHM = 'BQACAgIAAxkBAAIQ516ujb8gr_Rdosi8WeBN2G7HMFRHAALCBQAC5jhxSdNM5MrBzeNbGQQ'
  INF = 'BQACAgIAAxkBAAIQ3V6ujVZcFFD5QnfAaEo3TmLtBIIVAAK9BQAC5jhxSUMwTFPNvt5TGQQ'
  ENG = 'BQACAgIAAxkBAAIQ316ujXgXyjuLVS8fVZzmAhKQjPCEAAK-BQAC5jhxSZuYDBu5Cp9lGQQ'
  HIS = 'BQACAgIAAxkBAAIQ416ujaL7GYC6Sb-QdMKmqF7QFTcTAALABQAC5jhxSYi4HtPzuke4GQQ'
  PHY = 'BQACAgIAAxkBAAIQ5V6ujbJxUyOjeMblKBDF7Zn8MLiRAALBBQAC5jhxSS0b9sQI_lHUGQQ'

  def get_ids
    { 'Биология' => BIO, 'География' => GEO, 'Химия' => CHM, 'Информатика' => INF, 'Английский' => ENG, 'История' => HIS, 'Физика' => PHY }
  end
end
