# frozen_string_literal: true

require 'sqlite3'
require 'sequel'

class Database
  attr_reader :db, :id, :dataset, :table, :status
  def initialize(id: nil, status: nil)
    @id         = id.to_s
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
    dataset.insert(user_id: id, status: status) unless verificate
    puts('already registred') if verificate
  end

  def verificate
    dataset.each do |row|
      if row.values[1] == id && row.values[6] == 'in progress'
        return row.values[6]
      end
      return row.values[6] if row.values[1] == id && row.values[6] == 'accepted'
      if row.values[1] == id && row.values[6] == 'registered'
        return row.values[6]
      end
      return row.values[6] if row.values[1] == id && row.values[6] == 'name'
      return row.values[6] if row.values[1] == id && row.values[6] == 'link'
      return row.values[6] if row.values[1] == id && row.values[6] == 'subjects'
      return row.values[6] if row.values[1] == id && row.values[6] == 'photo'
      return true if row.values[1] == id && row.values[6].nil?
    end
    false
  end

  def update_data(name: nil, link: nil, photo: nil)
    dataset.filter(user_id: id).update(status: status)
    dataset.filter(user_id: id).update(name: name) unless name.nil?
    dataset.filter(user_id: id).update(link: link) unless link.nil?
    dataset.filter(user_id: id).update(image: photo) unless photo.nil?
  end

  def set_subjects(subjects:)
    arr = []
    dataset.each do |row|
      arr << row.values[4] if row.values[1] == id && !row.values[4].nil?
    end
    arr << subjects
    dataset.filter(user_id: id).update(subjects: arr.join(' '))
  end

  def get_subjects
    arr = String.new
    dataset.each do |row|
      arr = row.values[4] if row.values[1] == id
    end
    arr.split(' ')
  end

  def del_subjects
    dataset.filter(user_id: id).update(subjects: nil)
  end

  def get_request
    dataset.each do |row|
      return row if row.values[1] == id
    end
  end

  def delete_user_progress
    dataset.filter(user_id: id).delete
  end
end
