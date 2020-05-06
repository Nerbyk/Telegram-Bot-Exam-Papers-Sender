# frozen_string_literal: true

class Verification
  attr_reader :client_id, :db
  def call(client_id:, db:)
    @client_id = client_id
    @db        = db
    check
  end

  def check
    db.call(id: client_id)
    db.verificate
  end
end
