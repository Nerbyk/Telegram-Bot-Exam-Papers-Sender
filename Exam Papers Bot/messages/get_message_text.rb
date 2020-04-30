require 'yaml'


class GetMessageText
  attr_reader :client, :replies_list
  def initialize(client: 'user')
    @client         = client
    @replies_list   = YAML.load(File.read('./messages/messages_examples/'+ client + '_messages.yml'))
  end

  def reply(case_text)
    text = replies_list[case_text]
  end

end
#
# text = GetMessageText.new()
# p text.reply('greeting_first_time_user')



# replies = YAML.load(
#   File.read("./user_messages.yml"))
#   text = replies["get_user_info_link"]
#   p text
