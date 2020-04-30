class GetUserInfo < MessageResponder
  attr_reader :bot, :message, :my_text
  def call(bot:, message:)
    super
  end

  def respond(client_id)
    puts("Test")
  end
end
