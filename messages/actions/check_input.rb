# frozen_string_literal: true

require './messages/actions/get_membership_status.rb'

class Check
  attr_reader :bot, :client_id
  def initialize(bot: nil, client_id: nil)
    @bot        = bot
    @client_id  = client_id
  end

  MAX_SUBJECTS = 6
  def name(name)
    return false if name.split(' ').length > 2 || name.split.length == 1

    true
  end

  def membership(link)
    return false unless link.include?('vk')
    if link.include?('nerby1') || link.include?('48857393')
      return false
    end # if my link was passed

    vk_status = CheckId.new(link: link).get_membership_info
    # telegram_status = CheckStatus.new(bot: bot, client_id: client_id).get_membership_status
    # telegram_status  &&
    vk_status ? true : false
  end

  def each_subject(input)
    available_list = %w[Биология География Химия Информатика Английский История Физика Закончить\ Ввод]
    available_list.include?(input) ? false : true
  end

  def all_subjects(subjects)
    if subjects.length > MAX_SUBJECTS || subjects.length > subjects.uniq.length
      subjects.uniq.length
      false
    else
      true
    end
  end
end
