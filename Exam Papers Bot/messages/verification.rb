
require './Database/database.rb'
class Verification
  attr_reader :client_id
  def call(client_id: )
    @client_id = client_id
    check
  end

  def check
    Database.new(id: client_id).verificate
  end

end
