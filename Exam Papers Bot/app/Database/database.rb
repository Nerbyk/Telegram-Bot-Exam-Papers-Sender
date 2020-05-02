# frozen_string_literal: true

require 'sqlite3'
require 'sequel'
require './messages/status_constants.rb'
class Database
  attr_reader :db, :id, :dataset, :table, :status, :user_name
  def initialize(id: nil, status: nil, user_name: nil)
    @id         = id.to_s
    @status     = status
    @user_name  = user_name
    @table      = :user_details
    @db         = Sequel.sqlite('./Database/user_details.db')
    @dataset    = create
  end

  def create
    db.create_table? table do
      primary_key :id
      String :user_id
      String :user_name
      String :name
      String :link
      String :subjects
      Blob   :image
      String :status
    end
    dataset = db[table]
  end

  def registrate
    dataset.insert(user_id: id, status: status, user_name: user_name) unless verificate
    puts('already registred') if verificate
  end

  def verificate
    dataset.each do |row|
      if row[:user_id] == id && Status.new.get.include?(row[:status])
        return row[:status]
      else
        true
      end
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
      arr << row[:subjects] if row[:user_id] == id && !row[:subjects].nil?
    end
    arr << subjects
    dataset.filter(user_id: id).update(subjects: arr.join(' '))
  end

  def get_subjects
    arr = String.new
    dataset.each do |row|
      arr = row[:subjects] if row[:user_id] == id
    end
    arr.split(' ')
  end

  def del_subjects
    dataset.filter(user_id: id).update(subjects: nil)
  end

  def get_request
    dataset.each do |row|
      return row if row[:user_id] == id
    end
  end

  def delete_user_progress
    dataset.filter(user_id: id).delete
  end

  def admin_get_request
    dataset.each do |row|
      return row if row[:subjects] == Status::IN_PROGRESS
    end
    return false
  end

end
