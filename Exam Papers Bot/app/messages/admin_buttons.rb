# frozen_string_literal: true

require './messages/admin_responder.rb'
require './messages/files_to_send/send_files.rb'

class AdminButton < AdminResponder
  attr_reader :bot, :message, :user_input, :my_text, :client_id
  def call(bot:, message:, user_input:)
    super
  end

  def respond(_client_id)
    case message.data
    when 'Accept'
      request = Database.new.admin_get_request
      subjects = request[:subjects]
      user_id = request[:user_id].to_i
      answer_to_client(user_id, my_text.reply('inpect_accept_message_to_user'))
      SendFiles.new(bot, user_id, subjects)
      Database.new(id: user_id.to_s, status: Status::ACCEPTED).update_data
      inspect_requests
    when 'Deny'
      request = Database.new.admin_get_request
      user_id = request[:user_id].to_i
      answer_to_client(user_id, my_text.reply('inspect_deny_message_to_user'))
      Database.new(id: user_id.to_s).delete_user_progress
      inspect_requests
    when 'Ban'
      request = Database.new.admin_get_request
      user_id = request[:user_id].to_i
      answer_to_client(user_id, my_text.reply('insepct_ban_message_to_user'))
      Database.new(id: user_id.to_s, status: Status::BAN).update_data
    when 'Menu'
      answer_menu
    end
  end
end
