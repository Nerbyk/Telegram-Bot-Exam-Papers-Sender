# frozen_string_literal: true

require 'requests/sugar'
require 'dotenv'
Dotenv.load('./.env')

token = ENV['VK_TOKEN']
group_id = 69_201_889
v = 5.103

class CheckId
  attr_reader :link, :token, :group_id, :v
  def initialize(link:)
    @link     = link
    @token    = ENV['VK_TOKEN']
    @group_id = 69_201_889
    @v        = 5.103
    extraction
  end

  def extraction
    @link = @link.split('/')
    @link = @link.last
    @link.include?('id') ? @link.slice!('id') : @link
    get_numeric_id unless is_int?
  end

  def is_int?
    true if Int(@link)
  rescue StandardError
    false
  end

  def get_numeric_id
    r = Requests.get('https://api.vk.com/method/users.get', params: { 'access_token': token, 'v': v, 'user_ids': @link, 'fields': 'id' })
    vk_id = r.json['response']
    @link = vk_id[0]['id']
  end

  def get_membership_info
    r = Requests.get('https://api.vk.com/method/groups.isMember', params: { 'access_token': token, 'v': v, 'group_id': group_id, 'user_id': @link.to_i })
    if r.json['response'] == 1
      true
    elsif r.json['response'] == 0
      false
    end
  end
end

class CheckStatus
  attr_reader :bot, :client_id, :tg_status
  def initialize(bot: nil, client_id: nil)
    @bot        = bot
    @client_id  = client_id
    @tg_status  = tg_status
    status
  end

  def status
    @tg_status = bot.api.getChatMember(chat_id: '@pozor_brno', user_id: client_id)
    @tg_status = @tg_status['result']
    @tg_status = @tg_status['status']
  end

  def get_membership_status
    @tg_status != 'left'
  end
end
