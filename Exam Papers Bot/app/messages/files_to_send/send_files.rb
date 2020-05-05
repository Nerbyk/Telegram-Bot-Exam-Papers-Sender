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
    ReSendFile.new.call(bot: bot, chat: id, document: document)
  end
end

class ReSendFile
  def call(bot:, chat:, document:)
    bot.api.forward_message(chat_id: chat, from_chat_id: 143_845_427, message_id: document)
  end
end

class FileId
  BIO = 57
  GEO = 47
  CHM = 49
  INF = 55
  ENG = 59
  HIS = 53
  PHY = 51

  def get_ids
    { 'Биология' => BIO, 'География' => GEO, 'Химия' => CHM, 'Информатика' => INF, 'Английский' => ENG, 'История' => HIS, 'Физика' => PHY }
  end
end
