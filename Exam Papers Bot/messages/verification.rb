

class Verification
  attr_reader :client_id
  def call(client_id: )
    @client_id = client_id
    check
  end

  def check 

  end

end
