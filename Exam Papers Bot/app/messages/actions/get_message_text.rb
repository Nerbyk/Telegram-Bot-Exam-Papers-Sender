# frozen_string_literal: true

require 'yaml'
class GetMessageText
  attr_reader :client, :replies_list
  def initialize(client: 'user')
    @client         = client
    @replies_list   = YAML.safe_load(File.read('./messages/messages_examples/' + client + '_messages.yml'))
  end

  def reply(case_text)
    text = replies_list[case_text]
  end
end




