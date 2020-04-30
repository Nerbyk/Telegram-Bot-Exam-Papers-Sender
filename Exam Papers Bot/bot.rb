# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|

  end
end
