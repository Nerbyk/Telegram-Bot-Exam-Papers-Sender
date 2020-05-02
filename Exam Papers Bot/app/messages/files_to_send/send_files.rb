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
      sleep(3)
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
  BIO = 'BQACAgIAAxkBAAINyl6tBMXAplmTgV0i_BPeI9c5w5pcAAKcBQACbF5oSbNAUtUnfyMgGQQ'
  GEO = 'BQACAgIAAxkBAAINzF6tBMisK3VRpuaXbDz4OgeCRCQzAAKdBQACbF5oSa11pTdbOChWGQQ'
  CHM = 'BQACAgIAAxkBAAIN1F6tBNVyjdc1YiwUCCXNbT2HAtuHAAKhBQACbF5oSVZQVhu_llORGQQ'
  INF = 'BQACAgIAAxkBAAINzl6tBMsEUZuUe8u8Hbfupe90KoaZAAKeBQACbF5oSeyaWXx9rvWDGQQ'
  ENG = 'BQACAgIAAxkBAAINyF6tBMGL-6wmjBLruH6mEAcYhgqRAAKbBQACbF5oSV-ZgCMF0qeoGQQ'
  HIS = 'BQACAgIAAxkBAAIN0F6tBM63UlmTBIy--UMP5R3wEwXMAAKfBQACbF5oSbnsw22a6uobGQQ'
  PHY = 'BQACAgIAAxkBAAIN0l6tBNIRFFbqx6nJgNVrT4R1vAhSAAKgBQACbF5oSWFAYBx6_a2aGQQ'

  def get_ids
    { 'Биология' => BIO, 'География' => GEO, 'Химия' => CHM, 'Информатика' => INF, 'Английский' => ENG, 'История' => HIS, 'Физика' => PHY }
  end
end
