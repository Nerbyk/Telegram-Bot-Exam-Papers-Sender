# frozen_string_literal: true

require 'sqlite3'
require 'sequel'

class Database
  attr_reader :db, :id, :dataset, :table
  def initialize(id: nil, status: nil)
    @id         = id
    @status     = status
    @table      = :user_details
    @db         = Sequel.sqlite('./Database/user_details.db')
    @dataset    = create
  end

  def create
    db.create_table? table do
      primary_key :id
      String :user_id
      String :name
      String :link
      String :subjects
      Blob   :image
      String :status
    end
    dataset = db[table]
  end

  def registrate
    p verificate
    dataset.insert(user_id: id, status: status) if !verificate
   puts("already registred") if verificate
  end

  def verificate
    dataset.each do |row|
      p row
      return row.values[6] if row.values[1] == id && row.values[6] == 'in progress'
      return row.values[6] if row.values[1] == id && row.values[6] == 'accepted'
      return row.values[6] if row.values[1] == id && row.values[6] == 'registered'
      return row.values[6] if row.values[1] == id && row.values[6] == 'name'
      return row.values[6] if row.values[1] == id && row.values[6] == 'link'
      return true if row.values[1] == id && row.values[6] == nil
    end
    false
  end

  def make_record(user_data)
    dataset.insert(user_id: user_data[0], name: user_data[1], link: user_data[2], subjects: user_data[3], image: user_data[4], status: user_data[5])
  end

  def update_status
    dataset.filter(user_id: id).update(:status => status)
  end

end